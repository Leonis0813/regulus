require 'csv'
require 'fileutils'
require 'mysql2'
require_relative 'config/settings'

TMP_FILE = 'tmp/rates.csv'
DAY = ARGV[0] ? ARGV[0] : (Date.today - 2).strftime('%F')

rates = Dir["/mnt/smb/*_#{DAY}.csv"].inject([]) do |rates, csv|
  rates += CSV.read(csv, :converters => :all)
end

rates.sort_by! {|rate| [rate[0], rate[1]] }
rates.map! {|rate| [rate[0].strftime('%F %T'), rate[1], rate[2], rate[3]] }

CSV.open(TMP_FILE, 'w') do |csv|
  rates.each {|rate| csv << rate }
end

client = Mysql2::Client.new(Settings.mysql)

query =<<"EOF"
LOAD DATA LOCAL INFILE
  '#{TMP_FILE}'
INTO TABLE
  rates
FIELDS TERMINATED BY
  ','
(@1, @2, @3, @4)
SET time=@1, pair=@2, bid=@3, ask=@4
EOF
client.query(query)

query =<<"EOF"
SELECT
  *
FROM
  rates
WHERE
  DATE(time) = '#{DAY}'
EOF
result = client.query(query)

client.close

rates = result.map {|r| [r['id'], r['time'].strftime('%F %T'), r['pair'], r['bid'], r['ask']] }

CSV.open("backup/#{DAY}.csv", 'w') do |csv|
  rates.each {|rate| csv << rate }
end

FileUtils.rm(TMP_FILE)
