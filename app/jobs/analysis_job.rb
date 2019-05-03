class AnalysisJob < ActiveJob::Base
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [
      "'#{analysis.from.strftime('%F %T')}'",
      "'#{analysis.to.strftime('%F %T')}'",
      analysis.batch_size,
    ]
    script_dir = Rails.root.join('scripts')
    FileUtils.mkdir_p(File.join(script_dir, 'tmp'))
    ret = system "sudo docker exec regulus python /opt/scripts/learn.py #{args.join(' ')}"
    FileUtils.mv(File.join(script_dir, 'tmp'), Rails.root.join('tmp', 'models', analysis_id.to_s))
    analysis.update!(state: 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/models/#{analysis_id}")
  end
end
