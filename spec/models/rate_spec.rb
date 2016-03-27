require 'rails_helper'

shared_context 'create rates' do |num_rate|
  before(:all) do
    num_rate.times do |i|
      rate = Rate.new
      rate.from_date = Time.now - (i+1) * 300
      rate.to_date = Time.now - i
      rate.pair = 'USDJPY'
      rate.interval = '5-min'
      rate.open = 100.000 + i
      rate.close = 100.000 + i
      rate.high = 100.000 + i
      rate.low = 100.000 + i
      rate.save!
    end
  end

  after(:all) { Rate.delete_all }
end

describe Rate, :type => :model do
  context 'more than 30 rates in database' do
    include_context 'create rates', 50

    it 'should return 30 rates' do
      expect(Rate.get_rates('USDJPY', 5).size).to eq(30)
    end
  end

  context 'less than 30 rates in database' do
    include_context 'create rates', 5

    it 'should return 5 rates' do
      expect(Rate.get_rates('USDJPY', 5).size).to eq(5)
    end
  end

  it 'should return nil if pair is nil' do
    expect(Rate.get_rates(nil, 5)).to eq(nil)
  end

  it 'should return nil if interval is nil' do
    expect(Rate.get_rates('USDJPY', nil)).to eq(nil)
  end

  it 'should return nil if pair and interval are nil' do
    expect(Rate.get_rates(nil, nil)).to eq(nil)
  end

  it 'should return nil if invalid pair' do
    expect(Rate.get_rates('INVALID', 5)).to eq(nil)
  end

  it 'should return nil if invalid interval' do
    expect(Rate.get_rates('USDJPY', -1)).to eq(nil)
  end

  it 'should return nil if invalid pair and interval' do
    expect(Rate.get_rates('INVALID', -1)).to eq(nil)
  end
end
