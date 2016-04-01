require 'rails_helper'

describe CurrenciesController, :type => :controller do
  describe 'GET #update' do
    before(:all) do
      %w[USDJPY EURJPY GBPJPY].each do |pair|
        50.times do |i|
          currency = Currency.new
          currency.from_date = Time.now - (i+1) * 300
          currency.to_date = Time.now - i
          currency.pair = pair
          currency.interval = '5-min'
          currency.open = 100.000 + i
          currency.close = 100.000 + i
          currency.high = 100.000 + i
          currency.low = 100.000 + i
          currency.save!
        end
      end

      @expected_currencies = [].tap do |currencies|
        (100...130).each do |rate|
          currencies << [rate.to_f] * 4
        end
      end
    end

    after(:all) { Currency.delete_all }

    it 'should return 50 currencies per pair' do
      request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
      get :update

      [:currencies_usd, :currencies_eur, :currencies_gbp].each do |currency|
        actual_currencies = assigns(currency).map {|currency| currency[1..-1] }
        expect(actual_currencies).to match_array @expected_currencies
      end
    end
  end
end
