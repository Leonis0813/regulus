class ArticlesController < ApplicationController
  def show
    @articles = Article.get_articles
  end

  def update
    @articles = Article.get_articles
  end
end
