require 'date'
require 'fileutils'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
yesterday = today - 1

query = <<"EOF"
SELECT
  *
FROM
  rates
WHERE
  time BETWEEN '#{yesterday.strftime('%Y-%m-%d 00:00:00')}' AND '#{yesterday.strftime('%Y-%m-%d 23:59:59')}'
ORDER BY
  time
EOF
rates = `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`

backup_dir = File.join(File.dirname(File.absolute_path(__FILE__)), "backup/rates/#{yesterday.strftime('%Y-%m')}")
FileUtils.mkdir_p backup_dir unless File.exists? backup_dir
csv_file = File.join(backup_dir, "#{yesterday.strftime('%d')}.csv")
File.open(csv_file, 'w') do |out|
  rates.split("\n").each {|rate| out.puts(rate.tr("\t", ',')) }
end

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[dump]',
  "{date: #{yesterday.strftime('%F')}, csv_file: #{csv_file}}",
].join(' ')
