require 'date'
require 'fileutils'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
yesterday = today - 1

query = <<"EOF"
SELECT
  *
FROM
  currencies
WHERE
  DATE(time) = '#{yesterday.strftime('%F')}'
ORDER BY
  time
EOF
rates = `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`

backup_dir = "backup/currencies/#{yesterday.strftime('%Y-%m')}"
FileUtils.mkdir_p backup_dir unless File.exists? backup_dir
csv_file = "#{backup_dir}/#{yesterday.strftime('%d')}.csv"
File.open(csv_file, 'w') do |out|
  rates.split("\n").each {|rate| out.puts(rate.tr("\t", ',')) }
end

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[dump]',
  "{date: #{yesterday.strftime('%F')}, csv_file: #{csv_file}}",
].join(' ')
