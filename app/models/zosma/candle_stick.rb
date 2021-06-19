module Zosma
  class CandleStick < Zosma::Base
    scope :daily, -> { where(time_frame: 'D1') }
    scope :between, ->(from, to) { where('`from` BETWEEN ? AND ?', from, to) }
  end
end
