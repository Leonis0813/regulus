class Tweet < ActiveRecord::Base
  validates :content, :presence => true
  validates :date, :presence => true, :format => /\d{4}-\d{2}-\d{2}/

  def self.get_tweets
    Tweet.order('created_at DESC').limit(20)
  end
end
