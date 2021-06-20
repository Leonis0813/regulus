# coding: utf-8

require 'rails_helper'

describe Evaluation, type: :model do
  shared_examples '更新情報がブロードキャストされていること' do
    it_is_asserted_by { @called }
  end

  shared_examples '更新した状態がブロードキャストされていること' do |state|
    it "状態が#{state}になっていること" do
      is_asserted_by { @evaluation.state == state }
    end

    it_behaves_like '更新情報がブロードキャストされていること'
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        evaluation_id: ['0' * 32],
        model: ['analysis.zip'],
        from: %w[1000-01-01],
        to: %w[1001-01-01],
        log_loss: [1, 0.1, nil],
        state: %w[waiting processing completed error],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      absent_keys = %i[model]
      invalid_attribute = {
        evaluation_id: ['invalid', 'g' * 32],
        model: %w[invalid],
        from: [0, nil],
        to: [0, nil],
        log_loss: ['invalid', -0.1],
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

  describe '#start!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @evaluation = create(:evaluation)
      @evaluation.start!
    end

    it '実行開始日時が設定されていること' do
      is_asserted_by { @evaluation.performed_at.present? }
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Evaluation::STATE_PROCESSING
  end

  describe '#complete!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @evaluation = create(:evaluation)
      @evaluation.complete!
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Evaluation::STATE_COMPLETED
  end

  describe '#failed!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @evaluation = create(:evaluation)
      @evaluation.failed!
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Evaluation::STATE_ERROR
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
        @evaluation = create(:evaluation)
        @evaluation.set_analysis!
      end

      it '分析情報が紐付けられていること' do
        is_asserted_by { @evaluation.reload.analysis == @analysis }
      end

      it_behaves_like '更新情報がブロードキャストされていること'
    end

    describe '異常系' do
      include_context 'トランザクション作成'
      include_context 'ActionCableのモックを作成'
      before { @analysis = build(:analysis) }
      include_context 'メタデータファイルを作成'
      before do
        @evaluation = create(:evaluation)
        @exceptioon = nil
        begin
          @evaluation.set_analysis!
        rescue StandardError => e
          @exception = e
        end
      end

      it 'StandardErrorが発生していること' do
        is_asserted_by { @exception.is_a?(StandardError) }
      end
    end
  end

  describe '#create_test_data!' do
    from = '1000-01-01'
    to = '1000-01-31'

    describe '正常系' do
      [
        [0.1, 0.2, 'up'],
        [0.2, 0.1, 'down'],
      ].each do |open_from, open_to, expected|
        context "正解が#{expected}の場合" do
          include_context 'トランザクション作成'
          include_context 'ActionCableのモックを作成'
          before do
            @analysis = create(:analysis)

            mockClass = Zosma::CandleStick
            allow(mockClass).to receive(:daily).and_return(Zosma::CandleStick)
            allow(mockClass).to receive(:between).and_return(Zosma::CandleStick)
            allow(mockClass).to receive(:where) do
              [
                Zosma::CandleStick.new(open: open_from),
                Zosma::CandleStick.new(open: open_to),
              ]
            end

            @evaluation = create(:evaluation, analysis: @analysis, from: from, to: to)
            @evaluation.create_test_data!
          end

          it 'テストデータが正しく登録されていること' do
            is_asserted_by do
              @evaluation.test_data.all? do |test_datum|
                test_datum.ground_truth == expected
              end
            end
          end
        end
      end
    end
  end

  describe '#calculate!' do
    describe '正常系' do
      include_context 'トランザクション作成'
      include_context 'ActionCableのモックを作成'
      before do
        @evaluation = create(:evaluation)
        [
          ['1000-01-01', '1000-01-20', nil, nil, 'up'],
          ['1000-01-02', '1000-01-21', 0.9, nil, 'up'],
          ['1000-01-03', '1000-01-22', nil, 0.3, 'down'],
          ['1000-01-04', '1000-01-23', 0.9, 0.1, 'up'],
          ['1000-01-05', '1000-01-24', 0.1, 0.9, 'down'],
        ].each do |from, to, up, down, ground_truth|
          @evaluation.test_data.create!(
            from: from,
            to: to,
            up_probability: up,
            down_probability: down,
            ground_truth: ground_truth,
          )
        end
        @evaluation.calculate!
      end

      it 'Log損失の値が正しいこと' do
        is_asserted_by do
          @evaluation.log_loss == -(Math.log(0.9) + Math.log(0.9)) / 2.0
        end
      end
    end
  end
end
