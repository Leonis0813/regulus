require 'date'
require 'fileutils'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

DUMP = Settings.tweet['dump']
ENV['TZ'] = 'UTC'

yesterday = (ARGV[0] ? Date.parse(ARGV[0]) : Date.today) - 1
backup_dir = File.join(DUMP['backup_dir'], yesterday.strftime('%Y-%m'))
FileUtils.mkdir_p backup_dir
csv_file = File.join(backup_dir, "#{yesterday.strftime('%d')}.csv")

File.open(csv_file, 'w') do |out|
  out.puts(DUMP['header'])

  param = {
    :from => yesterday.strftime('%Y-%m-%d 00:00:00'),
    :to => yesterday.strftime('%Y-%m-%d 23:59:59'),
  }
  tweets = execute_sql('regulus', File.join(Settings.application_root, 'tweets/dump.sql'), param)
  tweets.each {|tweet| out.puts(tweet.values.join(',')) }
end

Logger.write(
  'tweets',
  File.basename(__FILE__, '.rb'),
  {:date => yesterday.strftime('%F'), :csv_file => csv_file}
)
