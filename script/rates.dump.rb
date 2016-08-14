require 'date'
require 'fileutils'
require 'mysql2'
require_relative 'config/settings'

DUMP = Settings.rate['dump']
ENV['TZ'] = 'UTC'

today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
yesterday = today - 1

from = yesterday.strftime('%Y-%m-%d 00:00:00')
to = yesterday.strftime('%Y-%m-%d 23:59:59')
query = <<"EOF"
SELECT
  *
FROM
  rates
WHERE
  time BETWEEN '#{from}' AND '#{to}'
ORDER BY
  time
EOF

backup_dir = File.join(DUMP['backup_dir'], yesterday.strftime('%Y-%m'))
FileUtils.mkdir_p backup_dir
csv_file = File.join(backup_dir, "#{yesterday.strftime('%d')}.csv")

File.open(csv_file, 'w') do |out|
  out.puts(DUMP['header'])
  client = Mysql2::Client.new(Settings.mysql)
  client.query(query).each do |rate|
    out.puts(rate.values.join(','))
  end
  client.close
end

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[dump]',
  "{date: #{yesterday.strftime('%F')}, csv_file: #{csv_file}}",
].join(' ')
