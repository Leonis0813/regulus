# coding: utf-8
shared_context '記事を作成する' do |num_article|
  before(:all) do
    @articles = [].tap do |articles|
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
