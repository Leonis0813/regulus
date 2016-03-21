class Rate < ActiveRecord::Base
  scope :interval, ->(interval) { where(:interval => interval) }
  scope :pair, ->(pair) { where(:pair => pair) }

  def self.get_rates(pair, interval)
    return nil if Rate.pair(pair).select(:pair).distinct.count(:pair) == 0
    return nil unless interval && interval > 0

    [].tap do |arr|
      Rate.pair(pair).interval("#{interval}-min").order('to_date DESC').select('to_date, open, close, high, low').limit(30).each do |record|
        arr << [(record.to_date + 1).strftime('%Y-%m-%d %H:%M:%S'), record.open, record.high, record.low, record.close]
      end
    end
  end
end
