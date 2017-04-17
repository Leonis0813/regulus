require 'csv'
require_relative 'helper'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

def backup(date)
  file_name = backup_file(date)

  Logger.write_with_runtime(:file_name => File.basename(file_name)) do
    CSV.open(file_name, 'w') do |csv|
      get_rates(date).each do |rate|
        csv << [rate['id'], rate['time'].strftime('%F %T'), rate['pair'], rate['bid'], rate['ask']]
      end
    end
  end
end
