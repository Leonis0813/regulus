# coding: utf-8
require 'rails_helper'

describe ArticlesController, :type => :controller do
  include_context '記事を作成する', 20
  include_context 'ユーザー名とパスワードをセットする'
  include_context 'レスポンス初期化'
  include_context 'ArticlesControllerインスタンス変数初期化'
  before(:each) do
    @res ||= xhr(:get, :update)
    @articles ||= assigns[:articles]
  end
  it_behaves_like 'ステータスコードが正しいこと'
  it_behaves_like 'インスタンス変数(articles)が正しいこと'
end
