require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  def teardown
    Currency.delete_all
  end

  test 'should return currency infos' do
    assert_equal 5, Currency.get_currencies('USDJPY', 5).size
  end

  test 'should return 30 currency infos' do
    (5...50).each do |i|
      currency = Currency.new
      currency.time = Time.now - (i+1) * 300
      currency.pair = 'USDJPY'
      currency.rate = 100.000 + i
      currency.save!
    end
    currencies = Currency.get_currencies('USDJPY', 5)

    assert_equal 30, currencies.size
    currencies.first[1..-1].each do |rate|
      assert_equal 100.000, rate
    end
  end

  test 'should return nil if pair is nil' do
    currency = Currency.get_currencies(nil, 5)
    assert_nil currency
  end

  test 'should return nil if interval is nil' do
    currency = Currency.get_currencies('USDJPY', nil)
    assert_nil currency
  end

  test 'should return nil if pair and interval are nil' do
    currency = Currency.get_currencies(nil, nil)
    assert_nil currency
  end

  test 'should return nil if invalid pair' do
    currency = Currency.get_currencies('INVALID', 5)
    assert_nil currency
  end

  test 'should return nil if invalid interval' do
    currency = Currency.get_currencies('USDJPY', -1)
    assert_nil currency
  end

  test 'should return nil if invalid pair and interval' do
    currency = Currency.get_currencies('INVALID', -1)
    assert_nil currency
  end
end
