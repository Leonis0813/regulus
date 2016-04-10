class RatesController < ApplicationController
  def show
    @rates = Rate.get_rates('USDJPY', 5)
  end

  def update
    @rates = Rate.get_rates('USDJPY', 5)
    respond_to do |format|
      format.js
    end
  end
end
