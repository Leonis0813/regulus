# coding: utf-8
require 'rails_helper'

describe RatesController, :type => :controller do
  shared_context 'インスタンス変数初期化' do
    before(:all) do
      @res = nil
      @rates = nil
    end
  end

  shared_examples 'ステータスコードとインスタンス変数が正しいこと' do
    it { expect(@res.status).to eq(200) }
    it { expect(@rates.size).to eq(100) }
  end

  include_context 'レートを作成する', 150
  include_context 'ユーザー名とパスワードをセットする'
  
  describe 'GET #show' do
    include_context 'インスタンス変数初期化'
    before(:each) do
      @res ||= get(:show)
      @rates ||= assigns[:rates]
    end
    it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
  end

  describe 'GET #update' do
    include_context 'インスタンス変数初期化'
    before(:each) do
      @res ||= xhr(:get, :update, {:pair => 'USDJPY', :interval => '5-min'})
      @rates ||= assigns[:rates]
    end
    it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
  end
end
