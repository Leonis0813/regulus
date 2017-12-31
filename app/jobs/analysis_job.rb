class AnalysisJob < ActiveJob::Base
  queue_as :default

  def perform(num_data, interval)
    ret = system "Rscript #{Rails.root}/scripts/analyze/learn.r #{num_data} #{interval}"
    AnalysisMailer.finished(ret).deliver_now
  end
end
