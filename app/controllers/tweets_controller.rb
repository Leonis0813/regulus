class TweetsController < ApplicationController
  def show
    @tweets = Tweet.get_tweets
  end

  def update
    @tweets = Tweet.get_tweets
    respond_to do |format|
      format.js
    end
  end
end
