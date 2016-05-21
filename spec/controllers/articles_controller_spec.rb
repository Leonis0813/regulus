# coding: utf-8
require 'rails_helper'

describe ArticlesController, :type => :controller do
  shared_context 'インスタンス変数初期化' do
    before(:all) do
      @res = nil
      @articles = nil
    end
  end

  shared_examples 'ステータスコードとインスタンス変数が正しいこと' do
    it { expect(@res.status).to eq(200) }
    it do
      expected_articles = Article.all.map {|article| article.title }
      actual_articles = @articles.to_a.map {|article| article.title }
      expect(actual_articles).to match_array expected_articles
    end
  end

  include_context '記事を作成する', 20
  include_context 'ユーザー名とパスワードをセットする'

  describe 'GET #show' do
    include_context 'インスタンス変数初期化'
    before(:each) do
      @res ||= get(:show)
      @articles ||= assigns[:articles]
    end
    it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
  end

  describe 'GET #update' do
    include_context 'インスタンス変数初期化'
    before(:each) do
      @res ||= xhr(:get, :update)
      @articles ||= assigns[:articles]
    end
    it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
  end
end
