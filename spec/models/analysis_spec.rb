# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        from: ['1000-01-01 00:00:00'],
        to: ['1001-01-01 00:00:00'],
        pair: %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY],
        batch_size: 100,
        state: %w[processing completed error],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        from: ['invalid', 0, 0.0, nil],
        to: ['invalid', 0, 0.0, nil],
        pair: ['invalid', 0, 0.0, nil],
        batch_size: ['invalid', 0, 1.0, nil],
        state: ['invalid', 0, 0.0, nil],
      }
      invalid_period = {
        from: ['1000-01-02 00:00:00'],
        to: ['1000-01-01 00:00:00'],
      }
      absent_keys = invalid_attribute.keys - %i[from to pair]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
      it_behaves_like '不正な期間を指定した場合のテスト', invalid_period
    end
  end
end
