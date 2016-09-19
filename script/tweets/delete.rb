require 'date'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

DELETE = Settings.tweet['delete']
ENV['TZ'] = 'UTC'

created_at = (ARGV[0] ? Date.parse(ARGV[0]) : Date.today) << DELETE['period']
param = {:created_at => created_at.strftime('%Y-%m-%d 00:00:00')}
execute_sql('regulus', File.join(Settings.application_root, 'tweets/delete.sql'), param)
Logger.write('tweets', File.basename(__FILE__, '.rb'), {:date => created_at.strftime('%F')})
