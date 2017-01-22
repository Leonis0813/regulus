require 'csv'
require 'mysql2'
require_relative 'helper'
require_relative '../config/settings'
require_relative '../lib/logger'

def backup(date)
  client = Mysql2::Client.new(Settings.mysql)
  query = File.read(File.join(Settings.application_root, 'aggregate/backup.sql'))
  start_time = Time.now
  result = client.query(query.gsub('$DAY', date.strftime('%F')))
  end_time = Time.now
  client.close

  rates = result.map {|r| [r['id'], r['time'].strftime('%F %T'), r['pair'], r['bid'], r['ask']] }

  CSV.open(backup_file(date), 'w') do |csv|
    rates.each {|rate| csv << rate }
  end
  Logger.write({'file_name' => File.basename(backup_file(date)), '# of rate' => rates.size, 'mysql_runtime' => (end_time - start_time)})
end
