class Rate < ActiveRecord::Base
  scope :interval, ->(interval) { where(:interval => interval) }
  scope :pair, ->(pair) { where(:pair => pair) }

  def self.get_rates(pair, interval)
    return nil if Rate.pair(pair).size == 0
    return nil unless interval

    [].tap do |arr|
      Rate.pair(pair).interval(interval).order('to_date DESC').select('to_date, open, close, high, low').limit(100).each do |record|
        arr << {
          :time => (record.to_date + 1).strftime('%Y-%m-%d %H:%M:%S'),
          :open => record.open,
          :high => record.high,
          :low => record.low,
          :close => record.close,
        }
      end
    end
  end
end
