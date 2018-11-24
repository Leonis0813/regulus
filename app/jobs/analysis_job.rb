class AnalysisJob < ActiveJob::Base
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [
      "'#{analysis.from.strftime('%F %T')}'",
      "'#{analysis.to.strftime('%F %T')}'",
      analysis.batch_size,
    ]
    script_dir = '/opt/scripts'
    FileUtils.mkdir(File.join(script_dir, 'tmp'))
    ret = system "sudo docker exec regulus python #{File.join(script_dir, 'learn.py')} #{args.join(' ')}"
    FileUtils.mv(File.join(script_dir, 'tmp'), File.join(Rails.root, 'tmp/models', analysis_id))
    analysis.update!(:state => 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
  end
end
