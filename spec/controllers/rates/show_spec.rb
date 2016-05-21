# coding: utf-8
require 'rails_helper'

describe RatesController, :type => :controller do
  shared_context 'インスタンス変数初期化' do
    before(:all) do
      @res = nil
      @rates = nil
    end
  end

  shared_examples 'ステータスコードが正しいこと' do
    it { expect(@res.status).to eq(200) }
  end

  shared_examples 'インスタンス変数(rates)が正しいこと' do |num_rate|
    it { expect(@rates.size).to eq(num_rate) }
  end

  include_context 'ユーザー名とパスワードをセットする'

  context '正常系' do
    [
      ['USDJPY', '5-min', 100],
      ['EURJPY', '5-min', 99],
      ['USDJPY', '10-min', 98],
      ['GBPJPY', '30-min', 97],
    ].each do |pair, interval, num_rate|
      include_context 'レートを作成する', pair, interval, num_rate
    end
  
    [
      [{}, 100],
      [{:pair => 'EURJPY'}, 99],
      [{:interval => '10-min'}, 98],
      [{:pair => 'GBPJPY', :interval => '30-min'}, 97],
    ].each do |query, num_rate|
      context "#{query}の場合" do
        include_context 'インスタンス変数初期化'
        before(:each) do
          @res ||= get(:show, query)
          @rates ||= assigns[:rates]
        end
        it_behaves_like 'ステータスコードが正しいこと'
        it_behaves_like 'インスタンス変数(rates)が正しいこと', num_rate
      end
    end
  end

  context '異常系' do
    [
      {:pair => 'INVALID'},
      {:interval => 'INVALID'},
      {:pair => 'INVALID', :interval => 'INVALID'},
      {:pair => ['USDJPY'], :interval => {:min => 5}},
    ].each do |query|
      context "#{query}の場合" do
        include_context 'インスタンス変数初期化'
        before(:each) do
          @res ||= get(:show, query)
          @rates ||= assigns[:rates]
        end
        it '@ratesがnilであること' do
          expect(@rates).to be_nil
        end
      end
    end
  end
end
