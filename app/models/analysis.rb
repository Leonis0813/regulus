class Analysis
  include ActiveModel::Model

  attr_accessor :num_data, :interval

  validates :num_data, :numericality => {:only_integer => true, :greater_than => 0}
  validates :interval, :numericality => {:only_integer => true, :greater_than => 0}
end
