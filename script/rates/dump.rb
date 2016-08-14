require 'date'
require 'fileutils'
require_relative '../config/settings'
require_relative '../lib/mysql_client'

DUMP = Settings.rate['dump']
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
  rates = execute_sql('regulus', File.join(Settings.application_root, 'rates/dump.sql'), param)
  rates.each {|rate| out.puts(rate.values.join(',')) }
end

puts [
  "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
  '[dump]',
  "{date: #{yesterday.strftime('%F')}, csv_file: #{csv_file}}",
].join(' ')
