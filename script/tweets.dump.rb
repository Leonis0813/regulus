require 'date'
require 'fileutils'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
yesterday = today - 1

query = <<"EOF"
SELECT
  *
FROM
  tweets
WHERE
  created_at BETWEEN '#{yesterday.strftime('%Y-%m-%d 00:00:00')}' AND '#{yesterday.strftime('%Y-%m-%d 23:59:59')}'
ORDER BY
  created_at
EOF
tweets = `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`

backup_dir = "backup/tweets/#{yesterday.strftime('%Y-%m')}"
FileUtils.mkdir_p backup_dir unless File.exists? backup_dir
csv_file = "#{backup_dir}/#{yesterday.strftime('%d')}.csv"
File.open(csv_file, 'w') do |out|
  tweets.split("\n").each {|tweet| out.puts(tweet.tr("\t", ',')) }
end
