# coding: utf-8
require 'rails_helper'

describe Prediction, :type => :model do
  shared_context 'Predictionオブジェクトを検証する' do |params|
    before(:all) do
      @prediction = Prediction.new(params)
      @prediction.validate
    end
  end

  shared_examples '検証結果が正しいこと' do |result|
    it_is_asserted_by { @prediction.errors.empty? == result }
  end

  shared_examples 'エラーメッセージが正しいこと' do |expected_messages|
    it_is_asserted_by { @prediction.errors.messages == expected_messages }
  end

  describe '#validates' do
    describe '正常系' do
      valid_params = {
        :from => [
          nil, '1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101',
          '1000-01-01 00:00:00', '1000/01/01 00:00:00', '01-01-1000 00:00:00', '01/01/1000 00:00:00', '10000101 00:00:00',
        ],
        :to => [
          nil, '1001-01-01', '1001/01/01', '01-01-1001', '01/01/1001', '10010101',
          '1001-01-01 00:00:00', '1001/01/01 00:00:00', '01-01-1001 00:00:00', '01/01/1001 00:00:00', '10010101 00:00:00',
        ],
        :result => [nil, 'up', 'down', 'range'],
        :state => %w[ processing completed ],
      }

      test_cases = CommonHelper.generate_test_case(valid_params).select do |test_case|
        test_case.keys == valid_params.keys
      end

      test_cases.each do|params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Predictionオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      valid_params = {:state => 'processing'}
      invalid_params = {:result => %w[ invalid ], :state => [nil, 'invalid']}

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Predictionオブジェクトを検証する', valid_params.merge(params)
          it_behaves_like '検証結果が正しいこと', false
          it_behaves_like 'エラーメッセージが正しいこと', params.map {|key, _| [key, ['invalid']] }.to_h
        end
      end

      invalid_period = {
        :from => %w[ 1000-01-02 1000/01/02 02-01-1000 02/01/1000 10000102 ],
        :to => %w[ 1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101 ],
      }

      test_cases = CommonHelper.generate_test_case(invalid_params.merge(invalid_period)).select do |test_case|
        test_case.include?(:from) and test_case.include?(:to)
      end

      test_cases.each do |params|
        context '期間が不正な場合' do
          include_context 'Predictionオブジェクトを検証する', valid_params.merge(params)

          it_behaves_like '検証結果が正しいこと', false
          it_behaves_like 'エラーメッセージが正しいこと', params.map {|key, _| [key, ['invalid']] }.to_h
        end
      end
    end
  end
end