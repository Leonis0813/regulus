require 'date'

ENV['TZ'] = 'UTC'
today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
yesterday = (today - 1).strftime('%F')

query = <<"EOF"
SELECT
  *
FROM
  currencies
WHERE
  DATE(time) = '#{yesterday}'
ORDER BY
  time
EOF
rates = `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`

csv_file = "#{yesterday}.csv"
File.open(csv_file, 'w') do |out|
  rates.split("\n").each {|rate| out.puts(rate.tr("\t", ',')) }
end

system "tar zcf backup/#{yesterday}.tar.gz #{csv_file}"
system "rm #{csv_file}"
