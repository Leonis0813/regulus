class AnalysisJob < ActiveJob::Base
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    script_dir = Rails.root.join('scripts')
    FileUtils.mkdir_p(File.join(script_dir, 'tmp'))

    args = [
      "'#{analysis.from.strftime('%F %T')}'",
      "'#{analysis.to.strftime('%F %T')}'",
      analysis.batch_size,
    ]
    command = "sudo docker exec regulus python /opt/scripts/learn.py #{args.join(' ')}"
    ret = system(command)

    from = File.join(script_dir, 'tmp')
    to = Rails.root.join('tmp', 'models', analysis_id.to_s)
    FileUtils.mv(from, to)
    analysis.update!(state: 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/models/#{analysis_id}")
  end
end
