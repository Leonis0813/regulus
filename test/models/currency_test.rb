require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  def teardown
    Currency.delete_all
  end

  test 'should return currency infos included no info array' do
    currencies = Currency.get_currencies('USDJPY', 5)

    assert_equal 30, currencies.size
    assert_equal 25, currencies.select{|cur| cur[1..-1] == [0.0, 0.0, 0.0, 0.0] }.size
  end

  test 'should return currency infos' do
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
end
