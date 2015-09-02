require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  def teardown
    Tweet.delete_all
  end

  test 'should return recent tweets' do
    assert_equal 20, Tweet.get_tweets.size
  end

  test 'should return recent 100 tweets' do
    [].tap do |tweets|
      (20...120).each do |i|
        tweet = Tweet.new
        tweet.tweet_id = i
        tweet.user_name = "user#{i}"
        tweet.profile_image_url = "http://example.com/#{i}"
        tweet.full_text = "tweet for test"
        tweet.tweeted_at = Time.now - i
        tweet.created_at = Time.now + i
        tweets << tweet
      end

      tweets.shuffle.each {|tweet| tweet.save! }
    end

    assert_equal 100, Tweet.get_tweets.size
  end
end
