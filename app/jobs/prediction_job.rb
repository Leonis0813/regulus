require 'zip'

class PredictionJob < ApplicationJob
  include ModelUtil

  queue_as :regulus

  def perform(prediction_id, model_dir)
    prediction = Prediction.find(prediction_id)
    tmp_dir = Rails.root.join('scripts', 'tmp')

    FileUtils.rm_rf(tmp_dir)
    FileUtils.mkdir_p(tmp_dir)
    unzip_model(File.join(model_dir, prediction.model), tmp_dir)

    prediction.update!(pair: YAML.load_file(File.join(tmp_dir, 'metadata.yml'))['pair'])

    execute_script('predict.py')

    FileUtils.mv(File.join(tmp_dir, 'result.yml'), model_dir)
    result = YAML.load_file(File.join(model_dir, 'result.yml'))
    prediction.update!(result.merge(state: Prediction::STATE_COMPLETED))
    FileUtils.rm_rf(tmp_dir)
    FileUtils.rm_rf(model_dir) if prediction.means == Prediction::MEANS_MANUAL
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    prediction.update!(state: Prediction::STATE_ERROR)
  end
end
