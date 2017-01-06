require 'mysql2'
require_relative 'config/settings'
client = Mysql2::Client.new(Settings.mysql)
query =<<"EOF"
LOAD DATA LOCAL INFILE
  '/tmp/test.csv'
INTO TABLE
  rates
FIELDS TERMINATED BY
  ','
(@1, @2, @3, @4)
SET time=@1, pair=@2, bid=@3, ask=@4
EOF
client.query(query)
client.close
