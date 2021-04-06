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

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      absent_keys = %i[model]
      invalid_attribute = {
        prediction_id: ['invalid', 'g' * 32],
        model: %w[invalid],
        means: %w[invalid],
        result: %w[invalid],
        state: %w[invalid],
      }
      invalid_period = {
        from: %w[1000-01-02 1000/01/02 02-01-1000 02/01/1000 10000102],
        to: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
      }

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
      it_behaves_like '不正な期間を指定した場合のテスト', invalid_period
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
      FileUtils.mkdir_p(Rails.root.join('tmp')
      result_file = Rails.root.join('tmp/result.yml')
      @attribute = {result: 'up', from: '2000-01-01 00:00:00', to: '2000-01-01 01:00:00'}
      File.open(result_file, 'w') do |file|
        YAML.dump(@attribute, file)
      end
      @prediction = create(:prediction)
      @prediction.import_result!(result_file)
    end

    after { FileUtils.rm_rf(Rails.root.join('tmp')) }

    it '予測結果がDBに保存されていること' do
      is_asserted_by { @prediction.result == @attribute[:result] }
      is_asserted_by { @prediction.from == Time.zone.parse(@attribute[:from]) }
      is_asserted_by { @prediction.to == Time.zone.parse(@attribute[:to]) }
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
