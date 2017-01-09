require 'date'
Dir['import/*.rb'].each {|file| require file }

import
backup
delete

aggregation_date = (Date.today - 2).to_datetime
(0...1440).each do |offset|
  end_date = aggregation_date + Rational(offset, 24 * 60)

  %w[ min hour day month year ].each do |time_name|
    send(time_name, end_date).each do |interval, begin_date|
      Settings.import['pairs'].each do |pair|
        param = {
          :begin => begin_date.strftime('%Y-%m-%d %H:%M:%S'),
          :end => (end_date - Rational(1, 24 * 60 * 60)).strftime('%Y-%m-%d %H:%M:%S'),
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
