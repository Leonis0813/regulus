require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  def setup
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
  end

  test 'should return articles' do
    expected_articles = Article.get_articles

    @controller.update
    assert_equal expected_articles, assigns(:articles)
  end
end
