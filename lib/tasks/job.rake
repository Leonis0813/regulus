namespace :job do
  desc 'Execute prediction'
  task prediction: :environment do
    if File.exist?(setting_file)
      setting = YAML.load_file(setting_file)

      if setting['status'] == 'active'
        attribute = {
          model: setting['filename'],
          means: Prediction::MEANS_AUTO,
          state: Prediction::STATE_PROCESSING,
        }
        prediction = Prediction.create!(attribute)
        model_dir = Rails.root.join(config.base_model_dir, config.auto.model_dir)
        PredictionJob.perform_later(prediction.id, model_dir.to_s)
      end
    end
  end

  def setting_file
    File.join(rails_root, config.auto.setting_file)
  end

  def config
    Settings.prediction
  end

  def rails_root
    require 'pathname'
    Pathname.new(__FILE__) + '../../../'
  end
end
