require_relative '../config/settings'

module Logger
  FILE_PATH = File.join(Settings.application_root, 'log/aggregate.log')

  def self.write(text)
    operate = File.basename(caller[0][/^([^:]+):\d+:in `[^']*'$/, 1], '.rb')
    body = ["[#{Time.now.strftime('%F %T.%6N')}]", "[#{operate}]", text.to_s].join(' ')
    File.open(FILE_PATH, 'a') {|file| file.puts(body) }
  end

  def self.write_with_runtime
    start_time = Time.now
    text = yield
    end_time = Time.now
    operate = File.basename(caller[0][/^([^:]+):\d+:in `[^']*'$/, 1], '.rb')
    body = ["[#{Time.now.strftime('%F %T.%6N')}]", "[#{operate}]", text.merge('runtime' => end_time - start_time).to_s].join(' ')
    File.open(FILE_PATH, 'a') {|file| file.puts(body) }
  end
end
