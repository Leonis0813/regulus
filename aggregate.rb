require 'date'
require_relative 'config/settings'
require_relative 'lib/logger'
require_relative 'lib/mysql_client'
Dir['aggregate/*.rb'].each {|file| require_relative file }

TARGET_DATE = Date.today - 2

Logger.write('Start aggregation')
Logger.write("Target date: #{TARGET_DATE.strftime('%F')}")
if rate_files(TARGET_DATE).empty?
  Logger.write('Not found rate files')
else
  Logger.write('Start importing')
  import(TARGET_DATE)
  Logger.write('Finish importing')
  backup(TARGET_DATE)

  aggregation_date = TARGET_DATE.to_datetime
  (1..1440).each do |offset|
    end_date = aggregation_date + Rational(offset, 24 * 60)

    Settings.interval.keys.each do |time_name|
      send(time_name, end_date).each do |interval, begin_date|
        Settings.pairs.each do |pair|
          param = {
            :begin => begin_date.strftime('%F %T'),
            :end => (end_date - Rational(1, 24 * 60 * 60)).strftime('%F %T'),
            :pair => pair,
            :interval => interval,
          }
          start_time = Time.now
          create_candle_sticks(param)
          end_time = Time.now
          Logger.write(:param => param, :mysql_runtime => (end_time - start_time))
        end
      end
    end
  end
end
Logger.write('Finish aggregation')
