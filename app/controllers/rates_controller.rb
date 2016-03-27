class RatesController < ApplicationController
  def show
    @rates = Rate.get_rates('USDJPY', 5)
  end

  def update
    @rates = Rate.get_rates('USDJPY', 5)
  end
end
