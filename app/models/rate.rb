class Rate < ActiveRecord::Base
  scope :interval, ->(interval) { where(:interval => interval) }
  scope :pair, ->(pair) { where(:pair => pair) }

  class << self
    def get_rates(pair, interval)
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

    def get_moving_average(pair, interval)
      return nil if Rate.pair(pair).size == 0
      return nil unless interval

      [].tap do |arr|
        open_rates = Rate.pair(pair).interval(interval).order('to_date DESC').select('to_date, open').limit(174)
        (open_rates.size - 74) < 0 ? [] : (open_rates.size - 74).times do |i|
          arr << {
            :time => (open_rates[i].to_date + 1).strftime('%Y-%m-%d %H:%M:%S'),
            :average => open_rates[i..i+74].map(&:open).inject(:+)/75,
          }
        end
      end
    end
  end
end
