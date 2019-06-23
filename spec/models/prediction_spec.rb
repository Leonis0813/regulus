# coding: utf-8

require 'rails_helper'

describe Prediction, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        model: ['analysis.zip'],
        from: [
          '1000-01-01',
          '1000/01/01',
          '01-01-1000',
          '01/01/1000',
          '10000101',
          '1000-01-01 00:00:00',
          '1000/01/01 00:00:00',
          '01-01-1000 00:00:00',
          '01/01/1000 00:00:00',
          '10000101 00:00:00',
          nil,
        ],
        to: [
          '1001-01-01',
          '1001/01/01',
          '01-01-1001',
          '01/01/1001',
          '10010101',
          '1001-01-01 00:00:00',
          '1001/01/01 00:00:00',
          '01-01-1001 00:00:00',
          '01/01/1001 00:00:00',
          '10010101 00:00:00',
          nil,
        ],
        pair: %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY] + [nil],
        result: %w[up down range] + [nil],
        state: %w[processing completed error],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        model: ['invalid', 0, 0.0, nil],
        pair: ['invalid', 0, 0.0],
        result: %w[invalid],
        state: ['invalid', nil],
      }
      invalid_period = {
        from: %w[1000-01-02 1000/01/02 02-01-1000 02/01/1000 10000102],
        to: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
      }
      absent_keys = invalid_attribute.keys - %i[pair result]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
      it_behaves_like '不正な期間を指定した場合のテスト', invalid_period
    end
  end
end
