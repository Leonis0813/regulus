require 'date'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today

query = <<"EOF"
DELETE FROM
  currencies
WHERE
  DATE(time) < '#{(today << 2).strftime('%F')}'
EOF
`mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[delete]',
  "{date: #{(today << 2).strftime('%F')}}",
].join(' ')
