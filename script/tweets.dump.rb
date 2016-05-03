require 'date'
require 'fileutils'
require 'mysql2'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
yesterday = today - 1

backup_dir = "backup/tweets/#{yesterday.strftime('%Y-%m')}"
FileUtils.mkdir_p backup_dir unless File.exists? backup_dir
csv_file = "#{backup_dir}/#{yesterday.strftime('%d')}.csv"

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

File.open(csv_file, 'w') do |out|
  out.puts('tweet_id,user_name,profile_image_url,full_text,tweeted_at,created_at')
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => 'regulus')
  client.query(query).each do |tweet|
    out.puts(tweet.values.join(','))
  end
  client.close
end

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[dump]',
  "{date: #{yesterday.strftime('%F')}, csv_file: #{csv_file}}",
].join(' ')
