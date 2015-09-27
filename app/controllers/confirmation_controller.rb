class ConfirmationController < ApplicationController
  def show
    @currencies_usd = Currency.get_currencies('USDJPY', 5)
    @currencies_eur = Currency.get_currencies('EURJPY', 5)
    @currencies_gbp = Currency.get_currencies('GBPJPY', 5)
    @tweets = Tweet.get_tweets
    @articles = Article.get_articles
    render :status => :ok
  end

  def update_currency
    @currencies_usd = Currency.get_currencies('USDJPY', 5)
    @currencies_eur = Currency.get_currencies('EURJPY', 5)
    @currencies_gbp = Currency.get_currencies('GBPJPY', 5)
  end

  def update_tweet
    @tweets = Tweet.get_tweets
  end

  def update_article
    @articles = Article.get_articles
  end
end
