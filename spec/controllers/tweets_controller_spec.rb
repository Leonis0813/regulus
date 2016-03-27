# coding: utf-8
require 'rails_helper'

describe TweetsController, :type => :controller do
  shared_examples 'ステータスコードとインスタンス変数が正しいこと' do
    it '' do
      expected_tweets = @tweets.map {|tweet| tweet.tweet_id }
      actual_tweets = assigns(:tweets).to_a.map {|tweet| tweet.tweet_id }

      expect(response.status).to eq(200)
      expect(actual_tweets).to match_array expected_tweets
    end
  end

  include_context 'ツイートを作成する', 100

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
