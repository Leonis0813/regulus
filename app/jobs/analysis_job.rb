class AnalysisJob < ApplicationJob
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    script_dir = Rails.root.join('scripts')
    FileUtils.mkdir_p(File.join(script_dir, 'tmp'))

    param = {
      from: analysis.from.strftime('%F %T'),
      to: analysis.to.strftime('%F %T'),
      pair: analysis.pair,
      batch_size: analysis.batch_size,
      env: Rails.env.to_s,
    }.stringify_keys
    parameter_file = File.join(tmp_dir, 'parameter.yml')
    File.open(parameter_file, 'w') {|file| YAML.dump(param, file) }
    execute_script('learn.py')

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
