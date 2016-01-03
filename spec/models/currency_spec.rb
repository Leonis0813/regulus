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

  it 'should return nil if pair is nil' do
    expect(Currency.get_currencies(nil, 5)).to eq(nil)
  end

  it 'should return nil if interval is nil' do
    expect(Currency.get_currencies('USDJPY', nil)).to eq(nil)
  end

  it 'should return nil if pair and interval are nil' do
    expect(Currency.get_currencies(nil, nil)).to eq(nil)
  end

  it 'should return nil if invalid pair' do
    expect(Currency.get_currencies('INVALID', 5)).to eq(nil)
  end

  it 'should return nil if invalid interval' do
    expect(Currency.get_currencies('USDJPY', -1)).to eq(nil)
  end

  it 'should return nil if invalid pair and interval' do
    expect(Currency.get_currencies('INVALID', -1)).to eq(nil)
  end
end
