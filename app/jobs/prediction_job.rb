class PredictionJob < ActiveJob::Base
  queue_as :regulus

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    tmp_dir = File.join(Rails.root, 'scripts/tmp')
    FileUtils.mkdir_p(tmp_dir)

    model_dir = File.join(Rails.root, "tmp/models/#{prediction.id}")
    zip_file = File.join(model_dir, prediction.model)
    Zip::File.open(zip_file) do |zip|
      zip.each do |entry|
        zip.extract(entry, File.join(tmp_dir, entry.name))
      end
    end

    system 'sudo docker exec regulus python /opt/scripts/predict.py'

    FileUtils.mv(File.join(tmp_dir, 'result.yml'), model_dir)
    result = YAML.load_file(File.join(model_dir, 'result.yml'))
    prediction.update!(result.merge('state' => 'completed'))
    FileUtils.rm_rf([tmp_dir, model_dir])
  end
end
