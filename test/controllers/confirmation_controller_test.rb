require 'test_helper'

class ConfirmationControllerTest < ActionController::TestCase
  def setup
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
  end

  test 'should response as success' do
    get :show
    assert_response :success
  end

  test 'should describe <div> tag with id=currency' do
    get :show
    assert_select 'div#currency', 1
  end

  test 'should describe <div> taf with id=tweet' do
    get :show
    assert_select 'div#tweet', 1
  end

  test 'should describe <div> tag with id=article' do
    get :show
    assert_select 'div#article', 1
  end
end
