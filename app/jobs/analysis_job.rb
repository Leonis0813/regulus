class AnalysisJob < ApplicationJob
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    script_dir = Rails.root.join('scripts')
    FileUtils.mkdir_p(File.join(script_dir, 'tmp'))

    args = [
      "'#{analysis.from.strftime('%F %T')}'",
      "'#{analysis.to.strftime('%F %T')}'",
      analysis.pair,
      analysis.batch_size,
    ]
    execute_script('learn.py', args)

    from = File.join(script_dir, 'tmp')
    to = Rails.root.join('tmp', 'models', analysis_id.to_s)
    FileUtils.mv(from, to)
    File.open(File.join(to, 'metadata.yml'), 'w') do |file|
      YAML.dump({'pair' => analysis.pair}, file)
    end
    analysis.update!(state: 'completed')
    AnalysisMailer.completed(analysis).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/models/#{analysis_id}")
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    analysis.update!(state: 'error')
    AnalysisMailer.error(analysis).deliver_now
  end
end
