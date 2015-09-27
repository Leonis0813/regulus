class Article < ActiveRecord::Base
  def self.get_articles
    Article.order('created_at DESC').limit(20)
  end
end
