module Zosma
  class MovingAverage < Zosma::Base
    scope :daily, -> { where(time_frame: 'D1') }
  end
end
