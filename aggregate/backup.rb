require 'csv'
require 'mysql2'
require_relative '../config/settings'

def backup(date)
  date_str = date.strftime('%F')

  client = Mysql2::Client.new(Settings.mysql)
  query = File.read(File.join(Settings.application_root, 'aggregate/backup.sql'))
  client.query(query.gsub('$DAY', date_str))
  result = client.query(query)
  client.close

  rates = result.map {|r| [r['id'], r['time'].strftime('%F %T'), r['pair'], r['bid'], r['ask']] }

  CSV.open(File.join(Settings.application_root, Settings.backup_dir, "#{date_str}.csv"), 'w') do |csv|
    rates.each {|rate| csv << rate }
  end
end
