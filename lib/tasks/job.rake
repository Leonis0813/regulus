namespace :job do
  desc 'Execute prediction'
  task prediction: :environment do
    setting = YAML.load_file(setting_file)
    if setting['status'] == 'active'
      attribute = {
        model: setting['filename'],
        means: Prediction::MEANS_AUTO,
        state: Prediction::STATE_PROCESSING,
      }
      prediction = Prediction.create!(attribute)
      model_dir = Rails.root.join('tmp', 'models', 'auto')
      PredictionJob.perform_later(prediction.id, model_dir.to_s)
    end
  end

  def setting_file
    "#{rails_root}/config/prediction.yml"
  end

  def rails_root
    require 'pathname'
    Pathname.new(__FILE__) + '../../../'
  end
end
