class PredictedRate < Rate
  class << self
    def get_rates(pair, interval)
      return nil if ActualRate.pair(pair).size == 0
      return nil unless interval

      [].tap do |arr|
        ActualRate.pair(pair).interval(interval).order('to_date DESC').select('to_date, open, close, high, low').limit(100).each do |record|
          arr << {
            :time => (record.to_date + 1 + 9 * 60 * 60).strftime('%Y-%m-%d %H:%M:%S'),
            :open => record.open,
            :high => record.high,
            :low => record.low,
            :close => record.close,
          }
        end
      end
    end
  end
end
