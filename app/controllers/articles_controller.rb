class ArticlesController < ApplicationController
  def show
    @articles = Article.get_articles
  end

  def update
    @articles = Article.get_articles
    respond_to do |format|
      format.js
    end
  end
end
