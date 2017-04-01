require 'csv'
require_relative 'helper'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

def backup(date)
  start_time = Time.now
  rates = get_rates(date)
  end_time = Time.now

  file_name = backup_file(date)
  CSV.open(file_name, 'w') do |csv|
    rates.each do |rate|
      csv << [rate['id'], rate['time'].strftime('%F %T'), rate['pair'], rate['bid'], rate['ask']]
    end
  end

  Logger.write('file_name' => File.basename(file_name), '# of rate' => rates.size, 'mysql_runtime' => (end_time - start_time))
end
