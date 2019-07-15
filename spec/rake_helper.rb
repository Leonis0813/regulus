require 'rake'

RSpec.configure do |config|
  config.before(:suite) { Rails.application.load_tasks }
  config.before(:each) { Rake.application.tasks.each(&:reenable) }
end
