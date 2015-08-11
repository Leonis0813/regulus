class Article < ActiveRecord::Base
  validates :content, :presence => true
  validates :date, :presence => true, :format => /\d{4}-\d{2}-\d{2}/

  def self.get_articles
    'article'
  end
end
