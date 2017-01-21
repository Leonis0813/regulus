require 'csv'
require 'mysql2'
require_relative 'helper'
require_relative '../config/settings'

def backup(date)
  client = Mysql2::Client.new(Settings.mysql)
  query = File.read(File.join(Settings.application_root, 'aggregate/backup.sql'))
  result = client.query(query.gsub('$DAY', date.strftime('%F')))
  client.close

  rates = result.map {|r| [r['id'], r['time'].strftime('%F %T'), r['pair'], r['bid'], r['ask']] }

  CSV.open(backup_file(date), 'w') do |csv|
    rates.each {|rate| csv << rate }
  end
end
