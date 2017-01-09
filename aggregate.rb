require 'date'
require_relative 'config/settings'
Dir['aggregate/*.rb'].each {|file| require_relative file }

TARGET_DATE = Date.today - 2

unless Dir[rate_files(TARGET_DATE)].empty?
  import(TARGET_DATE)
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

          begin
            client = Mysql2::Client.new(Settings.mysql)
            query = File.read(File.join(Settings.application_root, 'aggregate.sql'))
            param.each {|key, value| query.gsub!("$#{key.upcase}", value) }
            client.query(query)
          rescue => e
            next
          ensure
            client.close
          end
        end
      end
    end
  end
end
