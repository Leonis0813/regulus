# coding: utf-8
require 'rails_helper'

describe ArticlesController, :type => :controller do
  shared_examples 'ステータスコードとインスタンス変数が正しいこと' do
    it '' do
      expected_articles = @articles.map {|article| article.title }
      actual_articles = assigns(:articles).to_a.map {|article| article.title }

      expect(response.status).to eq(200)
      expect(actual_articles).to match_array expected_articles
    end
  end

  include_context '記事を作成する', 20

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
