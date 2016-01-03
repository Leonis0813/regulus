require 'rails_helper'

describe TweetsController, :type => :controller do
  describe 'GET #update' do
    before(:all) do
      @tweets = [].tap do |tweets|
        100.times do |i|
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

    it 'should return 100 tweets' do
      request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
      get :update

      expected_tweets = @tweets.map {|tweet| tweet.tweet_id }
      actual_tweets = assigns(:tweets).to_a.map {|tweet| tweet.tweet_id }
      expect(actual_tweets).to match_array expected_tweets
    end
  end
end
