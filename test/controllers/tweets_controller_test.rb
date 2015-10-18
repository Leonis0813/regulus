require 'test_helper'

class TweetsControllerTest < ActionController::TestCase
  def setup
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
  end

  test 'should get tweets' do
    expected_tweets = Tweet.get_tweets

    @controller.update
    assert_equal expected_tweets, assigns(:tweets)
  end
end
