class ArticlesController < ApplicationController
  def update
    @articles = Article.get_articles
  end
end
