class Currency < ActiveRecord::Base
  scope :interval, ->(from, to) { where("time BETWEEN '#{from}' AND '#{to}'") }
  scope :pair, ->(pair) { where(:pair => pair) }

  def self.get_currencies(pair, interval)
    now = Time.now - 32400
    to = now - (now.min % interval) * 60
    [].tap do |arr|
      30.times do
        from = to - interval * 60
        results = Currency.pair(pair)
          .interval(from.strftime('%Y-%m-%d %H:%M:00'), to.strftime('%Y-%m-%d %H:%M:00'))
          .order(:time)
          .select(:rate)
        arr << [
                to.strftime('%H:%M:00'),
                results.first ? results.first.rate : 0.0,
                results.maximum(:rate) || 0.0,
                results.minimum(:rate) || 0.0,
                results.last ? results.last.rate : 0.0
               ]
        to = from
      end
    end
  end
end
