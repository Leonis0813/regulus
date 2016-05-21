# coding: utf-8
require 'rails_helper'

describe TweetsController, :type => :controller do
  shared_context 'インスタンス変数初期化' do
    before(:all) do
      @res = nil
      @tweets = nil
    end
  end

  shared_examples 'ステータスコードとインスタンス変数が正しいこと' do
    it { expect(@res.status).to eq(200) }
    it do
      expected_tweets = Tweet.all.map {|tweet| tweet.tweet_id }
      actual_tweets = @tweets.to_a.map {|tweet| tweet.tweet_id }
      expect(actual_tweets).to match_array expected_tweets
    end
  end

  include_context 'ツイートを作成する', 100
  include_context 'ユーザー名とパスワードをセットする'
  include_context 'インスタンス変数初期化'
  before(:each) do
    @res ||= xhr(:get, :update)
    @tweets ||= assigns[:tweets]
  end
  it_behaves_like 'ステータスコードとインスタンス変数が正しいこと'
end
