class TweetsController < ApplicationController
  def update
    @tweets = Tweet.get_tweets
    render :nothing => true
  end
end
