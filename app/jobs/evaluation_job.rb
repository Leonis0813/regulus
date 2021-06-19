require 'zip'

class EvaluationJob < ApplicationJob
  include ModelUtil

  queue_as :regulus

  def perform(evaluation)
    evaluation.start!

    tmp_dir = Rails.root.join('scripts/tmp')
    FileUtils.rm_rf(tmp_dir)
    FileUtils.mkdir_p(tmp_dir)
    model_dir = Rails.root.join(Settings.evaluation.base_model_dir, evaluation.id.to_s)
    unzip_model(File.join(model_dir, evaluation.model), tmp_dir)

    evaluation.set_analysis!
    evaluation.create_test_data!

    common_param = {
      min: evaluation.analysis.min,
      max: evaluation.analysis.max,
      pair: evaluation.analysis.pair,
      env: Rails.env.to_s,
    }

    evaluation.test_data.each do |test_datum|
      param = common_param.merge(to: test_datum.to.strftime('%F')).stringify_keys
      parameter_file = File.join(tmp_dir, 'parameter.yml')
      File.open(parameter_file, 'w') {|file| YAML.dump(param, file) }

      execute_script('predict.py')

      FileUtils.mv(File.join(tmp_dir, 'result.yml'), model_dir)
      test_datum.import_result!(File.join(model_dir, 'result.yml'))
      evaluation.calculate!
    end

    FileUtils.rm_rf(tmp_dir)
    FileUtils.rm_rf(model_dir)
    evaluation.complete!
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    evaluation.failed!
  end
end
