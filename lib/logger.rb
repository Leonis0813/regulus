require 'json'
require_relative '../config/settings'

module Logger
  FILE_PATH = File.join(Settings.application_root, 'log/aggregate.log')

  class << self
    def write(text)
      operate = File.basename(caller[0][/^([^:]+):\d+:in `[^']*'$/, 1], '.rb')
      body = ["[#{Time.now.strftime('%F %T.%6N')}]", "[#{operate}]", text.to_json].join(' ')
      File.open(FILE_PATH, 'a') {|file| file.puts(body) }
    end

    def write_with_runtime
      start_time = Time.now
      text = yield
      end_time = Time.now
      write text.merge(:runtime => end_time - start_time)
    end
  end
end
