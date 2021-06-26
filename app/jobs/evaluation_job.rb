class EvaluationJob < ApplicationJob
  include ModelUtil

  queue_as :regulus

  def perform(evaluation)
    evaluation.start!

    unzip_model(File.join(evaluation.model_dir, evaluation.model), tmp_dir)

    evaluation.set_analysis!
    evaluation.create_test_data!

    common_param = evaluation.analysis.slice(:min, :max, :pair)
                             .merge('env' => Rails.env.to_s)

    evaluation.test_data.each do |test_datum|
      File.open(File.join(tmp_dir, 'parameter.yml'), 'w') do |file|
        YAML.dump(common_param.merge('to' => test_datum.to.strftime('%F')), file)
      end

      execute_script('predict.py')

      FileUtils.mv(File.join(tmp_dir, 'result.yml'), evaluation.model_dir)
      test_datum.import_result!('result.yml')
      evaluation.calculate!
    end

    evaluation.complete!
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    evaluation.failed!
  end

  private

  def tmp_dir
    @tmp_dir ||= Settings.evaluation.tmp_dir
  end
end
