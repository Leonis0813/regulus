# coding: utf-8

shared_examples 'インスタンス変数(tweets)が正しいこと' do
  it do
    expected_tweets = Tweet.all.map {|tweet| tweet.tweet_id }
    actual_tweets = @tweets.to_a.map {|tweet| tweet.tweet_id }
    expect(actual_tweets).to match_array expected_tweets
  end
end
