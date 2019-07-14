require File.expand_path(File.dirname(__FILE__) + "/environment")
set :output, 'log/cron.log'
set :environment, (ENV['RAILS_ENV'] || 'development')

every '0 * * * 1-5' do
  runner 'PredictionUtil.execute'
end
