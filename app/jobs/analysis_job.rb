class AnalysisJob < ApplicationJob
  queue_as :regulus

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    analysis.start!

    tmp_dir = Rails.root.join('scripts/tmp')
    FileUtils.mkdir_p(tmp_dir)

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

    to = Rails.root.join('tmp', 'models', analysis_id.to_s)
    FileUtils.mv(tmp_dir, to)

    metadata = YAML.load_file(File.join(to, 'metadata.yml'))
    analysis.update!(metadata)
    File.open(File.join(to, 'metadata.yml'), 'w') do |file|
      YAML.dump({'analysis_id' => analysis.analysis_id}, file)
    end

    AnalysisMailer.completed(analysis).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/models/#{analysis_id}")
    analysis.completed!
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    analysis.failed!
    AnalysisMailer.error(analysis).deliver_now
  end
end
