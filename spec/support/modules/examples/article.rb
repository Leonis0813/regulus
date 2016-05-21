# coding: utf-8

shared_examples 'インスタンス変数(articles)が正しいこと' do
  it do
    expected_articles = Article.all.map {|article| article.title }
    actual_articles = @articles.to_a.map {|article| article.title }
    expect(actual_articles).to match_array expected_articles
  end
end
