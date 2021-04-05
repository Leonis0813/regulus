# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  shared_context 'モック作成' do
  end

  shared_examples '更新した状態がブロードキャストされていること' do |state|
    it "状態が#{state}になっていること" do
      is_asserted_by { @analysis.state == state }
    end

    it '状態がブロードキャストされていること' do
      is_asserted_by { @called }
    end
  end

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
        state: %w[waiting processing completed error],
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

  describe '#start!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @analysis = create(:analysis)
      @analysis.start!
    end

    it '実行開始日時が設定されていること' do
      is_asserted_by { @analysis.performed_at.present? }
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Analysis::STATE_PROCESSING
  end

  describe '#completed!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @analysis = create(:analysis)
      @analysis.completed!
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Analysis::STATE_COMPLETED
  end

  describe '#failed!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @analysis = create(:analysis)
      @analysis.failed!
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Analysis::STATE_ERROR
  end
end
