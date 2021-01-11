require 'zip'

class PredictionJob < ApplicationJob
  include ModelUtil

  queue_as :regulus

  MAX_RETRY = 60

  def perform(prediction_id, model_dir)
    prediction = Prediction.find(prediction_id)
    tmp_dir = Rails.root.join('scripts', 'tmp')

    FileUtils.rm_rf(tmp_dir)
    FileUtils.mkdir_p(tmp_dir)
    unzip_model(File.join(model_dir, prediction.model), tmp_dir)

    pair = YAML.load_file(File.join(tmp_dir, 'metadata.yml'))['pair']
    param = {pair: pair, env: Rails.env.to_s}.stringify_keys
    parameter_file = File.join(tmp_dir, 'parameter.yml')
    File.open(parameter_file, 'w') {|file| YAML.dump(param, file) }
    prediction.update!(pair: pair)

    if Settings.prediction.wait_latest and prediction.means == Prediction::MEANS_AUTO
      polling_zosma(pair)
    end
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

  private

  def polling_zosma(pair)
    found = false

    MAX_RETRY.times do
      found = Zosma::CandleStick.exists?(
        from: latest.strftime('%F 00:00:00'),
        to: latest.strftime('%F 23:59:59'),
        pair: pair,
        time_frame: 'D1',
      )
      break if found

      sleep(60)
    end
    raise StandardError unless found

    MAX_RETRY.times do
      found = Zosma::MovingAverage.exists?(
        time: latest.strftime('%F 00:00:00'),
        pair: pair,
        time_frame: 'D1',
      )
      break if found

      sleep(60)
    end
    raise StandardError unless found
  end

  def latest
    Time.zone.today.monday? ? 3.days.ago : 1.day.ago
  end
end
