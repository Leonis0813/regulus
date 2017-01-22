require_relative '../config/settings'

module Logger
  def self.write(text)
    operate = File.basename(caller[0][/^([^:]+):\d+:in `[^']*'$/, 1], '.rb')
    file_path = File.join(Settings.application_root, 'log/aggregate.log')
    body = ["[#{Time.now.strftime('%F %T.%L')}]", "[#{operate}]", text].join(' ')
    File.open(file_path, 'a') {|file| file.puts(body) }
  end
end
