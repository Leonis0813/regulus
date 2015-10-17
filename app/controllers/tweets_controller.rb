class TweetsController < ApplicationController
  def update
    @tweets = Tweet.get_tweets
  end
end
