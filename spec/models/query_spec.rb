# coding: utf-8

require 'rails_helper'

describe Query, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        means: %w[manual auto] + [nil],
        page: 2,
        pair: %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY] + [nil],
        per_page: 50,
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        means: %w[invalid],
        page: [0],
        pair: %w[invalid],
        per_page: [0],
      }

      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end
