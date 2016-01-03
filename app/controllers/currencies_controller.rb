class CurrenciesController < ApplicationController
  def update
    @currencies_usd = Currency.get_currencies('USDJPY', 5)
    @currencies_eur = Currency.get_currencies('EURJPY', 5)
    @currencies_gbp = Currency.get_currencies('GBPJPY', 5)
    render :nothing => true
  end
end
