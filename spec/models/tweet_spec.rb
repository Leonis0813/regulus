require 'rails_helper'

shared_context 'create tweets' do |num_tweet|
  before(:all) do
    [].tap do |tweets|
      num_tweet.times do |i|
        tweet = Tweet.new
        tweet.tweet_id = i+1
        tweet.user_name = "user#{i}"
        tweet.profile_image_url = "http://example.com/#{i}"
        tweet.full_text = "tweet for test"
        tweet.tweeted_at = Time.now - i
        tweet.created_at = Time.now + i
        tweets << tweet
      end

      tweets.shuffle.each {|tweet| tweet.save! }
    end
  end

  after(:all) { Tweet.delete_all }
end

describe Tweet do
  context 'more than 100 tweets in database' do
    include_context 'create tweets', 150

    it 'should return 100 tweets' do
      expect(Tweet.get_tweets.size).to eq(100)
    end
  end

  context 'less than 100 tweets in database' do
    include_context 'create tweets', 20

    it 'should return 20 tweets' do
      expect(Tweet.get_tweets.size).to eq(20)
    end
  end
end
