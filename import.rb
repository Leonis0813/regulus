require 'csv'
require 'mysql2'
require_relative 'config/settings'

day = ARGV[1] ? ARGV[1] : Date.today.strftime('%F')

rates = [].tap do |rates|
  Dir["/mnt/smb/*_#{day}.csv"].each do |csv|
    rates += CSV.read(csv, :converters => :all)
  end
end

rates.sort_by! {|rate| [rate[0], rate[1]] }
rates.map! {|rate| [rate[0].strftime('%F %T'), rate[1], rate[2], rate[3]] }

CSV.open('tmp/rate.csv', 'w') do |csv|
  rates.each do |rate|
    csv << rate
  end
end

client = Mysql2::Client.new(Settings.mysql)
query =<<"EOF"
LOAD DATA LOCAL INFILE
  'tmp/rate.csv'
INTO TABLE
  rates
FIELDS TERMINATED BY
  ','
(@1, @2, @3, @4)
SET time=@1, pair=@2, bid=@3, ask=@4
EOF
client.query(query)
client.close
