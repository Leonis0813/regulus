require 'date'
require_relative 'config/settings'
require_relative 'lib/mysql_client'

AGGREGATE = Settings.rate['aggregate']
CHECKER = AGGREGATE['checker']

def check(time_name, date)
  [].tap do |intervals|
    CHECKER[time_name].each {|check_time| intervals << "#{check_time}-#{time_name}" if date.send(time_name) % check_time == 0 }
  end
end

def min(date)
  intervals = check('min', date)
  intervals.map {|interval| [interval, date - Rational(interval.split('-').first.to_i, 24 * 60)] }
end

def hour(date)
  intervals = date.min == 0 ? check('hour', date) : []
  intervals.map {|interval| [interval, date - Rational(interval.split('-').first.to_i, 24)] }
end

def day(date)
  intervals = (date.min == 0 and date.hour == 0) ? check('hour', date) : []
  intervals.map {|interval| [interval, date - interval.split('-').first.to_i] }
end

def week(date)
  intervals = (date.min == 0 and date.hour == 0 and date.wday == 0) ? ['1-week', date - (7 * interval.split('-').first.to_i)] : []
end

def month(date)
  intervals = (date.min == 0 and date.hour == 0 and date.day == 1) ? check('month', date) : []
  intervals.map {|interval| [interval, date << interval.split('-').first.to_i] }
end

def year(date)
  intervals = (date.min == 0 and date.hour == 0 and date.day == 1 and date.month == 1) ? check('year', date) : []
  intervals.map {|interval| [interval, date << (12 * interval.split('-').first.to_i)] }
end

now = Time.now
end_date = (now - now.sec).to_datetime

%w[ min hour day week month year ].each do |time_name|
  send(time_name, end_date).each do |interval, begin_date|
    param = {
      :begin => begin_date.strftime('%Y-%m-%d %H:%M:%S'),
      :end => (end_date - Rational(1, 24 * 60 * 60)).strftime('%Y-%m-%d %H:%M:%S'),
      :interval => interval,
    }
    begin
      client = Mysql2::Client.new(Settings.mysql)
      query = File.read(File.join(Settings.application_root, 'aggregate.sql'))
      param.each {|key, value| query.gsub!("$#{key.upcase}", value) }
      client.query(query)
    rescue
      next
    ensure
      client.close
    end
  end
end
