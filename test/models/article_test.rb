require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test 'Articles::get_articles' do
    assert 20, Article.get_articles.size
  end
end
