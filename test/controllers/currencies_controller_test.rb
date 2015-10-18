require 'test_helper'

class CurrenciesControllerTest < ActionController::TestCase
  def setup 
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
  end

  test 'should get currencies' do
    expected_cur_usd = Currency.get_currencies('USDJPY', 5)
    expected_cur_eur = Currency.get_currencies('EURJPY', 5)
    expected_cur_gbp = Currency.get_currencies('GBPJPY', 5)

    @controller.update
    assert_equal expected_cur_usd, assigns(:currencies_usd)
    assert_equal expected_cur_eur, assigns(:currencies_eur)
    assert_equal expected_cur_gbp, assigns(:currencies_gbp)
  end
end
