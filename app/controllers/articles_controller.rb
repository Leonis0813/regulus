class ArticlesController < ApplicationController
  def update
    @articles = Article.get_articles
    render :nothing => true
  end
end
