require 'date'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

DELETE = Settings.rate['delete']
ENV['TZ'] = 'UTC'

time = (ARGV[0] ? Date.parse(ARGV[0]) : Date.today) << DELETE['period']
database = ARGV[1] || 'regulus'
param = {:time => time.strftime('%Y-%m-%d 00:00:00')}
execute_sql(database, File.join(Settings.application_root, 'rates/delete.sql'), param)
Logger.write('rates', File.basename(__FILE__, '.rb'), {:date => time.strftime('%F')})
