require 'rails_helper'

shared_context 'create currencies' do |num_currency|
  before(:all) do
    num_currency.times do |i|
      currency = Currency.new
      currency.from_date = Time.now - (i+1) * 300
      currency.to_date = Time.now - i
      currency.pair = 'USDJPY'
      currency.interval = '5-min'
      currency.open = 100.000 + i
      currency.close = 100.000 + i
      currency.high = 100.000 + i
      currency.low = 100.000 + i
      currency.save!
    end
  end

  after(:all) { Currency.delete_all }
end

describe Currency do
  context 'more than 30 currencies in database' do
    include_context 'create currencies', 50

    it 'should return 30 currencies' do
      expect(Currency.get_currencies('USDJPY', 5).size).to eq(30)
    end
  end

  context 'less than 30 currencies in database' do
    include_context 'create currencies', 5

    it 'should return 5 currencies' do
      expect(Currency.get_currencies('USDJPY', 5).size).to eq(5)
    end
  end
end
