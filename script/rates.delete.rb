require 'date'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today

query = <<"EOF"
DELETE FROM
  rates
WHERE
  time < '#{(today << 2).strftime('%Y-%m-%d 00:00:00')}'
EOF
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => 'regulus')
client.query(query)
client.close

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[delete]',
  "{date: #{(today << 2).strftime('%F')}}",
].join(' ')
