class Currency < ActiveRecord::Base
  validates :name, :presence => true
  validates :price, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :date, :presence => true, :format => /\d{4}-\d{2}-\d{2}/

  def self.get_currencies
    'currency'
  end
end
