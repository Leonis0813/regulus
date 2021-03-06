# coding: utf-8

require 'rails_helper'

describe Prediction, type: :model do
  shared_examples '更新情報がブロードキャストされていること' do
    it_is_asserted_by { @called }
  end

  shared_examples '更新した状態がブロードキャストされていること' do |state|
    it "状態が#{state}になっていること" do
      is_asserted_by { @prediction.state == state }
    end

    it_behaves_like '更新情報がブロードキャストされていること'
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        prediction_id: ['0' * 32],
        model: ['analysis.zip'],
        from: ['1000-01-01 00:00:00', nil],
        to: ['1001-01-01 00:00:00', nil],
        means: %w[manual auto] + [nil],
        result: %w[up down range] + [nil],
        state: %w[waiting processing completed error],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:prediction, attribute) }
          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      required_keys = %i[model]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}が設定されていない場合" do
          expected_error = absent_keys.map {|key| [key, 'absent'] }.to_h

          before(:all) do
            attribute = absent_keys.map {|key| [key, nil] }.to_h
            @object = build(:prediction, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        prediction_id: ['invalid', 'g' * 32],
        model: %w[invalid],
        means: %w[invalid],
        result: %w[invalid],
        state: %w[invalid],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid'] }.to_h

          before(:all) do
            @object = build(:prediction, attribute)
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
          @object = build(:prediction, attribute)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end

  describe '#set_analysis!' do
    shared_context 'メタデータファイルを作成' do
      before do
        tmp_dir = 'scripts/tmp'
        FileUtils.mkdir_p(Rails.root.join(tmp_dir))
        File.open(File.join(tmp_dir, 'metadata.yml'), 'w') do |file|
          file.puts("analysis_id: '#{@analysis.analysis_id}'")
        end
      end

      after { FileUtils.rm_rf(Rails.root.join('scripts/tmp')) }
    end

    describe '正常系' do
      include_context 'トランザクション作成'
      include_context 'ActionCableのモックを作成'
      before { @analysis = create(:analysis) }
      include_context 'メタデータファイルを作成'
      before do
        @prediction = create(:prediction)
        @prediction.set_analysis!
      end

      it '分析情報が紐付けられていること' do
        is_asserted_by { @prediction.reload.analysis == @analysis }
      end

      it_behaves_like '更新情報がブロードキャストされていること'
    end

    describe '異常系' do
      include_context 'トランザクション作成'
      include_context 'ActionCableのモックを作成'
      before { @analysis = build(:analysis) }
      include_context 'メタデータファイルを作成'
      before do
        @prediction = create(:prediction)
        @exceptioon = nil
        begin
          @prediction.set_analysis!
        rescue StandardError => e
          @exception = e
        end
      end

      it 'StandardErrorが発生していること' do
        is_asserted_by { @exception.is_a?(StandardError) }
      end
    end
  end

  describe '#import_result!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      FileUtils.mkdir_p(Rails.root.join('tmp'))
      result_file = Rails.root.join('tmp/result.yml')
      @attribute = {
        up: 0.99,
        down: 0.01,
        from: '2000-01-01 00:00:00',
        to: '2000-01-01 01:00:00',
      }.stringify_keys
      File.open(result_file, 'w') do |file|
        YAML.dump(@attribute, file)
      end
      @prediction = create(:prediction)
      @prediction.import_result!(result_file)
    end

    after { FileUtils.rm_rf(Rails.root.join('tmp')) }

    it '予測結果がDBに保存されていること' do
      is_asserted_by { @prediction.result == 'up' }
      is_asserted_by { @prediction.from == Time.zone.parse(@attribute['from']) }
      is_asserted_by { @prediction.to == Time.zone.parse(@attribute['to']) }
    end

    it_behaves_like '更新情報がブロードキャストされていること'
  end

  describe '#start!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @prediction = create(:prediction)
      @prediction.start!
    end

    it '実行開始日時が設定されていること' do
      is_asserted_by { @prediction.performed_at.present? }
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Prediction::STATE_PROCESSING
  end

  describe '#completed!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @prediction = create(:prediction)
      @prediction.completed!
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Prediction::STATE_COMPLETED
  end

  describe '#failed!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @prediction = create(:prediction)
      @prediction.failed!
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Prediction::STATE_ERROR
  end
end
