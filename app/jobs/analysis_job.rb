class AnalysisJob < ActiveJob::Base
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [analysis.from, analysis.to, analysis.batch_size]
    ret = system "sudo docker exec regulus python /opt/scripts/learn.py #{args.join(' ')}"
    analysis.update!(:state => 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
  end
end
