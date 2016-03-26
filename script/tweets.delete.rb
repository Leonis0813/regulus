require 'date'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today

query = <<"EOF"
DELETE FROM
  tweets
WHERE
  DATE(created_at) < '#{(today << 2).strftime('%F')}'
EOF
`mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`