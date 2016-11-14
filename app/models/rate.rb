class Rate < ActiveRecord::Base
  scope :interval, ->(interval) { where(:interval => interval) }
  scope :pair, ->(pair) { where(:pair => pair) }
end
