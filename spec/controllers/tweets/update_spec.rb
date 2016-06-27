# coding: utf-8
require 'rails_helper'

describe TweetsController, :type => :controller do
  include_context 'ツイートを作成する', 100
  include_context 'ユーザー名とパスワードをセットする'
  include_context 'レスポンス初期化'
  include_context 'TweetsControllerインスタンス変数初期化'
  before(:each) do
    @res ||= xhr(:get, :update)
    @tweets ||= assigns[:tweets]
  end
  it_behaves_like 'ステータスコードが正しいこと'
  it_behaves_like 'インスタンス変数(tweets)が正しいこと'
end
