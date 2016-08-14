require 'date'
require 'mysql2'
require_relative 'config/settings'

DELETE = Settings.tweet['delete']
ENV['TZ'] = 'UTC'

today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today

query = <<"EOF"
DELETE FROM
  tweets
WHERE
  created_at < '#{(today << DELETE['period']).strftime('%Y-%m-%d 00:00:00')}'
EOF
client = Mysql2::Client.new(Settings.mysql)
client.query(query)
client.close

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[delete]',
  "{date: #{(today << DELETE['period']).strftime('%F')}}",
].join(' ')
