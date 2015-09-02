require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  test 'Tweet::get_tweets' do
    assert_equal 20, Tweet.get_tweets.size
  end
end
