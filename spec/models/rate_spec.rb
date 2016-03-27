# coding: utf-8
require 'rails_helper'

shared_context 'レートを作成する' do |num_rate|
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

shared_context 'レートを取得する' do |params = {}|
  before(:all) { @res = Rate.get_rates(params[:pair], params[:interval]) }
end

shared_examples 'レートが取得されていること' do |expected_size|
  it { expect(@res.size).to eq(expected_size) }
end

shared_examples 'レートが取得されていないこと' do
  it { expect(@res).to be_nil }
end

describe Rate, :type => :model do
  [
    ['レート情報が十分にある場合', 50, 30],
    ['レート情報は不十分な場合', 5, 5],
  ].each do |description, num_rate, expected_size|
    context description do
      include_context 'レートを作成する', num_rate
      include_context 'レートを取得する', {:pair => 'USDJPY', :interval => 5}
      it_behaves_like 'レートが取得されていること', expected_size
    end
  end

  [
    ['為替ペアコードを指定しない場合', {:interval => 5}],
    ['期間を指定しない場合', {:pair => 'USDJPY'}],
    ['為替ペアコードと期間を指定しない場合', {}],
    ['為替ペアコードが不正な場合', {:pair => 'INVALID', :interval => 5}],
    ['期間が不正な場合', {:pair => 'USDJPY', :interval => -1}],
    ['為替ペアコードと期間が不正な場合', {:pair => 'INVALID', :interval => -1}],
  ].each do |description, params|
    context description do
      include_context 'レートを取得する', params
      it_behaves_like 'レートが取得されていないこと'
    end
  end
end
