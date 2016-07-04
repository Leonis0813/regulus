# coding: utf-8
require 'rails_helper'

describe RatesController, :type => :controller do
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
        include_context 'レスポンス初期化'
        include_context 'RatesControllerインスタンス変数初期化'
        before(:each) do
          @res ||= get(:show, query)
          @rates ||= assigns[:rates]
          @averages ||= assigns[:averages]
        end
        it_behaves_like 'ステータスコードが正しいこと'
        it_behaves_like 'インスタンス変数(rates)が正しいこと', num_rate
        it_behaves_like 'インスタンス変数(averages)が正しいこと', num_rate-74
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
        include_context 'レスポンス初期化'
        include_context 'RatesControllerインスタンス変数初期化'
        before(:each) { @res ||= get(:show, query) }

        %i[ rates averages ].each do |var_name|
          it "#{var_name}がnilであること" do
            expect(assigns[var_name]).to be_nil
          end
        end
      end
    end
  end
end
