namespace :job do
  desc 'Execute prediction'
  task prediction: :environment do
    if File.exist?(config_file)
      configs = YAML.load_file(config_file)

      configs.each do |config|
        next if config['status'] == 'inactive'

        attribute = {
          prediction_id: SecureRandom.hex,
          model: config['filename'],
          means: Prediction::MEANS_AUTO,
          state: Prediction::STATE_PROCESSING,
        }
        prediction = Prediction.create!(attribute)
        model_dir = Rails.root.join(
          Settings.prediction.base_model_dir,
          Settings.prediction.auto.model_dir,
          config['pair'],
        )
        PredictionJob.perform_later(prediction.id, model_dir.to_s)
      end
    end
  end

  def config_file
    File.join(rails_root, Settings.prediction.auto.config_file)
  end

  def rails_root
    require 'pathname'
    Pathname.new(__FILE__) + '../../../'
  end
end
