class RatesController < ApplicationController
  def update
    @rates_usd = Rate.get_rates('USDJPY', 5)
    @rates_eur = Rate.get_rates('EURJPY', 5)
    @rates_gbp = Rate.get_rates('GBPJPY', 5)
    render :nothing => true
  end
end
