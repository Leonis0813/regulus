require 'date'
require 'mysql2'
require_relative 'config/settings'

CHECKER = Settings.aggregate['checker']
END_DATE = (ARGV[0] ? ARGV[0] : (Date.today - 2).strftime('%F')).to_datetime

def check(time_name)
  [].tap do |intervals|
    CHECKER[time_name].each {|check_time| intervals << "#{check_time}-#{time_name}" if END_DATE.send(time_name) % check_time == 0 }
  end
end

def min
  intervals = check('min')
  intervals.map {|interval| [interval, END_DATE - Rational(interval.split('-').first.to_i, 24 * 60)] }
end

def hour
  intervals = END_DATE.min == 0 ? check('hour') : []
  intervals.map {|interval| [interval, END_DATE - Rational(interval.split('-').first.to_i, 24)] }
end

def day
  intervals = (END_DATE.min == 0 and END_DATE.hour == 0) ? check('hour') : []
  intervals.map {|interval| [interval, END_DATE - interval.split('-').first.to_i] }
end

def week
  intervals = (END_DATE.min == 0 and END_DATE.hour == 0 and END_DATE.wday == 0) ? ['1-week', END_DATE - (7 * interval.split('-').first.to_i)] : []
end

def month
  intervals = (END_DATE.min == 0 and END_DATE.hour == 0 and END_DATE.day == 1) ? check('month') : []
  intervals.map {|interval| [interval, END_DATE << interval.split('-').first.to_i] }
end

def year
  intervals = (END_DATE.min == 0 and END_DATE.hour == 0 and END_DATE.day == 1 and END_DATE.month == 1) ? check('year') : []
  intervals.map {|interval| [interval, END_DATE << (12 * interval.split('-').first.to_i)] }
end

%w[ min hour day week month year ].each do |time_name|
  send(time_name).each do |interval, begin_date|
    Settings.import['pairs'].each do |pair|
      param = {
        :begin => begin_date.strftime('%Y-%m-%d %H:%M:%S'),
        :end => (END_DATE - Rational(1, 24 * 60 * 60)).strftime('%Y-%m-%d %H:%M:%S'),
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
