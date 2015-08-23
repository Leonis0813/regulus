class Currency < ActiveRecord::Base
  validates :time, :presence => true
  validates :pair, :presence => true

  def self.get_currencies(pair)
    Currency.where("pair = '#{pair}'").order('time DESC').limit(21)
  end
end
