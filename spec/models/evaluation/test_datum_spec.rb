# coding: utf-8

require 'rails_helper'

describe Evaluation::TestDatum, type: :model do
  shared_examples '更新情報がブロードキャストされていること' do
    it_is_asserted_by { @called }
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        from: %w[1000-01-01],
        to: %w[1001-01-01],
        up_probability: [0, 1, 0.1, nil],
        down_probability: [0, 1, 0.1, nil],
        ground_truth: %w[up down],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) do
            @object = build(:evaluation_test_datum, attribute.merge(evaluation_id: 1))
          end

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      required_keys = %i[ground_truth]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}が設定されていない場合" do
          expected_error = absent_keys.map {|key| [key, 'absent'] }.to_h

          before(:all) do
            attribute = absent_keys.map {|key| [key, nil] }.to_h
            @object = build(:evaluation_test_datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        from: [0, nil],
        to: [0, nil],
        up_probability: [-0.1, 1.1],
        down_probability: [-0.1, 1.1],
        ground_truth: %w[invalid],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid'] }.to_h

          before(:all) do
            @object = build(:evaluation_test_datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_period = {
        from: %w[1000-01-02 1000/01/02 02-01-1000 02/01/1000 10000102],
        to: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
      }
      test_cases = CommonHelper.generate_test_case(invalid_period).select do |test_case|
        test_case.key?(:from) and test_case.key?(:to)
      end

      test_cases.each do |attribute|
        expected_error = {from: 'invalid', to: 'invalid'}

        before(:all) do
          @object = build(:evaluation_test_datum, attribute)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end

  describe '#import_result!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      evaluation = create(:evaluation)

      FileUtils.mkdir_p(evaluation.model_dir)
      @attribute = {
        up: 0.99,
        down: 0.01,
        from: '2000-01-01 00:00:00',
        to: '2000-01-01 01:00:00',
      }.stringify_keys
      File.open(File.join(evaluation.model_dir, 'result.yml'), 'w') do |file|
        YAML.dump(@attribute, file)
      end

      @test_datum = create(:evaluation_test_datum, evaluation_id: evaluation.id)
      @test_datum.import_result!('result.yml')
    end

    after { FileUtils.rm_rf(Rails.root.join('tmp')) }

    it '予測結果がDBに保存されていること' do
      is_asserted_by { @test_datum.up_probability == 0.99 }
      is_asserted_by { @test_datum.down_probability == 0.01 }
    end

    it_behaves_like '更新情報がブロードキャストされていること'
  end
end
