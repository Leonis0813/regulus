# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        analysis_id: ['0' * 32],
        from: ['1000-01-01 00:00:00'],
        to: ['1001-01-01 00:00:00'],
        pair: %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY],
        batch_size: 100,
        min: [1, 0.1, nil],
        max: [1, 0.1, nil],
        state: %w[processing completed error],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        analysis_id: ['invalid', 'g' * 32],
        from: [0, 0.0],
        to: [0, 0.0],
        pair: ['invalid'],
        batch_size: [0],
        min: [0],
        max: [0],
        state: ['invalid'],
      }
      invalid_period = {
        from: ['1000-01-02 00:00:00'],
        to: ['1000-01-01 00:00:00'],
      }

      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
      it_behaves_like '不正な期間を指定した場合のテスト', invalid_period
    end
  end
end
