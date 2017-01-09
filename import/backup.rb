require 'csv'
require 'mysql2'
require_relative '../config/setting'

def backup
  day = (Date.today - 2).strftime('%F')

  client = Mysql2::Client.new(Settings.mysql)

  query =<<"EOF"
SELECT
  *
FROM
  rates
WHERE
  DATE(time) = '#{day}'
EOF
  result = client.query(query)

  client.close

  rates = result.map {|r| [r['id'], r['time'].strftime('%F %T'), r['pair'], r['bid'], r['ask']] }

  CSV.open("backup/#{day}.csv", 'w') do |csv|
    rates.each {|rate| csv << rate }
  end
end
