class Tweet < ActiveRecord::Base
  def self.get_tweets
    Tweet.order('created_at DESC').limit(100)
  end
end
