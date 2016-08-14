require 'date'
require_relative '../config/settings'
require_relative '../lib/mysql_client'

DELETE = Settings.rate['delete']
ENV['TZ'] = 'UTC'

today = ARGV[0] ? Date.parse(ARGV[0]) : Date.today
param = {:time => (today << DELETE['period']).strftime('%Y-%m-%d 00:00:00')}
execute_sql('regulus', __FILE__.sub('.rb', '.sql'), param)

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[delete]',
  "{date: #{(today << DELETE['period']).strftime('%F')}}",
].join(' ')
