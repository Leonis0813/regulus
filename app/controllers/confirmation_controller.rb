class ConfirmationController < ApplicationController
  def show
    currencies = Currency.get_currencies('USDJPY')
    @currencies_usd = currencies.map.with_index do |cur, i|
      next if i > 19
      [
       cur.time.strftime('%H:%M:%S'),
       cur.open,
       cur.high,
       cur.low,
       currencies[i+1].open,
      ]
    end.compact

    currencies = Currency.get_currencies('EURJPY')
    @currencies_eur = currencies.map.with_index do |cur, i|
      next if i > 19
      [
       cur.time.strftime('%H:%M:%S'),
       cur.open,
       cur.high,
       cur.low,
       currencies[i+1].open,
      ]
    end.compact

    currencies = Currency.get_currencies('GBPJPY')
    @currencies_gbp = currencies.map.with_index do |cur, i|
      next if i > 19
      [
       cur.time.strftime('%H:%M:%S'),
       cur.open,
       cur.high,
       cur.low,
       currencies[i+1].open,
      ]
    end.compact

    @tweets = Tweet.get_tweets
    @articles = Article.get_articles
    render :status => :ok
  end

  def update_currency
    currencies = Currency.get_currencies('USDJPY')
    @currencies_usd = currencies.map.with_index do |cur, i|
      next if i > 19
      [
       cur.time.strftime('%H:%M:%S'),
       cur.open,
       cur.high,
       cur.low,
       currencies[i+1].open,
      ]
    end.compact

    currencies = Currency.get_currencies('EURJPY')
    @currencies_eur = currencies.map.with_index do |cur, i|
      next if i > 19
      [
       cur.time.strftime('%H:%M:%S'),
       cur.open,
       cur.high,
       cur.low,
       currencies[i+1].open,
      ]
    end.compact

    currencies = Currency.get_currencies('GBPJPY')
    @currencies_gbp = currencies.map.with_index do |cur, i|
      next if i > 19
      [
       cur.time.strftime('%H:%M:%S'),
       cur.open,
       cur.high,
       cur.low,
       currencies[i+1].open,
      ]
    end.compact
  end

  def update_tweet
    @tweets = Tweet.get_tweets
  end

  def update_article
    @articles = Article.get_articles
  end
end
