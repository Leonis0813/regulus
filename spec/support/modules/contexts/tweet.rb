# coding: utf-8
shared_context 'ツイートを作成する' do |num_tweet|
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
