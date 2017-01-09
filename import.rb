require 'date'
Dir['import/*.rb'].each {|file| require file }

import
backup
delete

aggregation_date = (Date.today - 2).to_datetime
(0...1440).each do |offset|
  aggregate(aggregation_date + Rational(offset, 24 * 60))
end
