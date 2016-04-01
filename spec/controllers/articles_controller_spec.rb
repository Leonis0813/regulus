require 'rails_helper'

describe ArticlesController, :type => :controller do
  describe 'GET #update' do
    before(:all) do
      @articles = [].tap do |articles|
        20.times do |i|
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

    it 'should return 20 articles' do
      request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
      get :update

      expected_articles = @articles.map {|article| article.title }
      actual_articles = assigns(:articles).to_a.map {|article| article.title }
      expect(actual_articles).to match_array expected_articles
    end
  end
end
