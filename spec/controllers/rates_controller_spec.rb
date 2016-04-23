# coding: utf-8
require 'rails_helper'

describe RatesController, :type => :controller do
  shared_examples 'ステータスコードとインスタンス変数が正しいこと' do
    it { expect(response.status).to eq(200) }
    it { expect(assigns[:rates].size).to eq(100) }
  end

  include_context 'レートを作成する', 150

  describe 'GET #show' do
    include_context 'ユーザー名とパスワードをセットする'
    before { get :show }
    it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
  end

  describe 'GET #update' do
    include_context 'ユーザー名とパスワードをセットする'
    before { xhr :get, :update }
    it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
  end
end
