# coding: utf-8

shared_context 'RatesControllerインスタンス変数初期化' do
  before(:all) { @rates = nil }
end

shared_context 'レートを作成する' do |pair, interval, num_rate|
  before(:all) do
    num_rate.times do |i|
      rate = Rate.new
      rate.from_date = Time.now - (i+1) * 300
      rate.to_date = Time.now - i
      rate.pair = pair
      rate.interval = interval
      rate.open = 100.000 + i
      rate.close = 100.000 + i
      rate.high = 100.000 + i
      rate.low = 100.000 + i
      rate.save!
    end
  end

  after(:all) { Rate.delete_all }
end
