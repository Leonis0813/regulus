# coding: utf-8
require 'rails_helper'

describe Analysis, :type => :model do
  shared_context 'Analysisオブジェクトを検証する' do |params|
    before(:all) do
      @analysis = Analysis.new(params)
      @analysis.validate
    end
  end

  shared_examples '検証結果が正しいこと' do |result|
    it_is_asserted_by { @analysis.errors.empty? == result }
  end

  shared_examples 'エラーメッセージが正しいこと' do |expected_messages|
    it_is_asserted_by { @analysis.errors.messages == expected_messages }
  end

  describe '#validates' do
    describe '正常系' do
      valid_params = {
        :from => %w[ 1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101 ],
        :to => %w[ 1001-01-01 1001/01/01 01-01-1001 01/01/1001 10010101 ],
        :batch_size => 100,
        :state => %w[ processing completed ],
      }

      test_cases = CommonHelper.generate_test_case(valid_params).select do |test_case|
        test_case.keys == valid_params.keys
      end

      test_cases.each do|params|
        include_context 'Analysisオブジェクトを検証する', params
        it_behaves_like '検証結果が正しいこと', true
      end
    end

    describe '異常系' do
      valid_params = {:from => '1000-01-01', :to => '1001-01-01', :batch_size => 100, :state => 'processing'}
      invalid_params = {
        :from => ['invalid', '1000-13-01', '1000-01-00', '1000-13-00', 1.0, 0, true, nil],
        :to => ['invalid', '1000-13-01', '1000-01-00', '1000-13-00', 1.0, 0, true, nil],
        :batch_size => ['invalid', -1, 0, true, nil],
        :state => ['invalid', 1.0, 0],
      }

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Analysisオブジェクトを検証する', valid_params.merge(params)
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
          include_context 'Analysisオブジェクトを検証する', valid_params.merge(params)

          it_behaves_like '検証結果が正しいこと', false
          it_behaves_like 'エラーメッセージが正しいこと', params.map {|key, _| [key, ['invalid']] }.to_h
        end
      end
    end
  end
end
