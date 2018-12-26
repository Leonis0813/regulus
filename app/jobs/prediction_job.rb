class PredictionJob < ActiveJob::Base
  queue_as :regulus

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    script_dir = File.join(Rails.root, 'scripts')
    FileUtils.mkdir_p(File.join(script_dir, 'tmp'))
    ret = system "sudo docker exec regulus python /opt/scripts/predict.py #{prediction.model}"
    FileUtils.mv(File.join(script_dir, 'tmp'), File.join(Rails.root, "tmp/models/#{prediction_id}"))
    prediction.update!(:from => nil, :to => nil, :result => nil, :state => 'completed')
    FileUtils.rm_rf("#{Rails.root}/tmp/models/#{prediction_id}")
  end
end
