class Currency < ActiveRecord::Base
  validates :time, :presence => true
  validates :pair, :presence => true

  def self.get_currencies
    Currency.order('time DESC').limit(20).select("DATE_FORMAT(time, '%Y-%m-%d %H:%i:%S') AS datetime, pair, bid")
  end
end
