module Zosma
  class CandleStick < Zosma::Base
    scope :daily, -> { where(time_frame: 'D1') }
  end
end
