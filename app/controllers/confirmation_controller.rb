class ConfirmationController < ApplicationController
  def show
    @currencies = Currency.get_currencies
    @tweets = Tweet.get_tweets
    @articles = Article.get_articles
    render :status => :ok
  end
end
