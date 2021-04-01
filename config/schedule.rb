require File.expand_path(File.dirname(__FILE__) + '/environment')
set :output, 'log/cron.log'
set :environment, (ENV['RAILS_ENV'] || 'development')

every :weekday, at: Time.parse('00:00:00').utc do
  rake 'job:prediction'
end
