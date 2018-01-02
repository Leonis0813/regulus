class AnalysisJob < ActiveJob::Base
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [analysis.num_data, analysis.interval]
    ret = system "Rscript #{Rails.root}/scripts/analyze/learn.r #{args.join(' ')}"
    analysis.update!(:state => 'completed')
    AnalysisMailer.finished(ret).deliver_now
  end
end
