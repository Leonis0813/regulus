require 'date'
require 'mysql2'
require_relative '../config/settings'

CHECKER = Settings.aggregate['checker']

def check(time_name, end_date)
  [].tap do |intervals|
    CHECKER[time_name].each {|check_time| intervals << "#{check_time}-#{time_name}" if end_date.send(time_name) % check_time == 0 }
  end
end

def min(end_date)
  intervals = check('min', end_date)
  intervals.map {|interval| [interval, end_date - Rational(interval.split('-').first.to_i, 24 * 60)] }
end

def hour(end_date)
  intervals = end_date.min == 0 ? check('hour', end_date) : []
  intervals.map {|interval| [interval, end_date - Rational(interval.split('-').first.to_i, 24)] }
end

def day(end_date)
  intervals = (end_date.min == 0 and end_date.hour == 0) ? check('hour', end_date) : []
  intervals.map {|interval| [interval, end_date - interval.split('-').first.to_i] }
end

def month(end_date)
  intervals = (end_date.min == 0 and end_date.hour == 0 and end_date.day == 1) ? check('month', end_date) : []
  intervals.map {|interval| [interval, end_date << interval.split('-').first.to_i] }
end

def year(end_date)
  intervals = (end_date.min == 0 and end_date.hour == 0 and end_date.day == 1 and end_date.month == 1) ? check('year', end_date) : []
  intervals.map {|interval| [interval, end_date << (12 * interval.split('-').first.to_i)] }
end

def aggregate(end_date)
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
