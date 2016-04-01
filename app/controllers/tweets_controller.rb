class TweetsController < ApplicationController
  def show
    @tweets = Tweet.get_tweets
  end

  def update
    @tweets = Tweet.get_tweets
  end
end
