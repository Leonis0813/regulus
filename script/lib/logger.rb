require_relative '../config/settings'

module Logger
  def write(resource, operate, text)
    file_path = File.join(Settings.application_root, "log/#{resource}.log")
    body = [
      "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
      "[#{operate}]",
      text,
    ].join(' ')
    File.open(file_path, 'a') do |file|
      file.puts(body)
    end
  end
end
