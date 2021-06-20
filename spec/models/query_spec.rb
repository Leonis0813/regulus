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

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:query, attribute) }
          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        means: %w[invalid],
        page: [0],
        pair: %w[invalid],
        per_page: [0],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid'] }.to_h

          before(:all) do
            @object = build(:query, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end
end
