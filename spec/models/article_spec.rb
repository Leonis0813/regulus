require 'rails_helper'

shared_context 'create articles' do |num_article|
  before(:all) do
    [].tap do |articles|
      num_article.times do |i|
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
  end

  after(:all) { Article.delete_all }
end

describe Article do
  context 'more than 20 articles in database' do
    include_context 'create articles', 100

    it 'should return 20 articles' do
      expect(Article.get_articles.size).to eq(20)
    end
  end

  context 'less than 20 articles in database' do
    include_context 'create articles', 5

    it 'should return 5 articles' do
      expect(Article.get_articles.size).to eq(5)
    end
  end
end
