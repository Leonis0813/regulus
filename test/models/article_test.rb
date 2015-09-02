require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def teardown
    Article.delete_all
  end

  test 'should return recent articles' do
    assert_equal 5, Article.get_articles.size
  end

  test 'should return recent 20 articles' do
    [].tap do |articles|
      (5...100).each do |i|
        article = Article.new
        article.published = '1999-12-31'
        article.title = "title#{i}"
        article.summary = "summary#{i}"
        article.url = "http://example.com/#{i}"
        article.created_at = Time.now + i
        articles << article
      end

      articles.shuffle.each {|article| article.save! }
    end

    assert_equal 20, Article.get_articles.size
  end
end
