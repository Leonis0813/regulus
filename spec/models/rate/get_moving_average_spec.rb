# coding: utf-8
require 'rails_helper'

describe Rate, :type => :model do
  shared_context '移動平均線を取得する' do |params = {}|
    before(:all) { @res = Rate.get_moving_average(params[:pair], params[:interval]) }
  end

  shared_examples '移動平均線が取得されていること' do |expected_size|
    it { expect(@res.size).to eq(expected_size) }
  end

  shared_examples '移動平均線が取得されていないこと' do
    it { expect(@res).to be_nil }
  end

  [
    ['レート情報が十分にある場合', 200, 100],
    ['レート情報が不十分な場合', 5, 0],
  ].each do |description, num_rate, expected_size|
    context description do
      include_context 'レートを作成する', 'USDJPY', '5-min', num_rate
      include_context '移動平均線を取得する', {:pair => 'USDJPY', :interval => '5-min'}
      it_behaves_like '移動平均線が取得されていること', expected_size
    end
  end

  [
    ['為替ペアコードを指定しない場合', {:interval => '5-min'}],
    ['期間を指定しない場合', {:pair => 'USDJPY'}],
    ['為替ペアコードと期間を指定しない場合', {}],
    ['為替ペアコードが不正な場合', {:pair => 'INVALID', :interval => '5-min'}],
    ['期間が不正な場合', {:pair => 'USDJPY', :interval => -1}],
    ['為替ペアコードと期間が不正な場合', {:pair => 'INVALID', :interval => -1}],
  ].each do |description, params|
    context description do
      include_context '移動平均線を取得する', params
      it_behaves_like '移動平均線が取得されていないこと'
    end
  end
end
