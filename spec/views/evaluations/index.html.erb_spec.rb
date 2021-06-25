# coding: utf-8

require 'rails_helper'

describe 'evaluations/index', type: :view do
  per_page = 1
  default_attribute = {model: 'analysis.zip', from: '1000-01-01', to: '1000-01-31'}
  displayed_state = {
    'waiting' => '実行待ち',
    'processing' => '実行中',
    'completed' => '完了',
    'error' => 'エラー',
  }

  shared_context '評価ジョブを登録する' do |total: per_page, attribute: default_attribute|
    before(:all) do
      analysis = create(:analysis, pair: Analysis::PAIR_LIST.sample)
      total.times do |i|
        attribute[:evaluation_id] = i.to_s * 32
        create(:evaluation, attribute.merge(analysis: analysis))
      end
      @evaluations = Evaluation.order(created_at: :desc).page(1)
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること', expected[:configs] || []
    it_behaves_like '表示件数情報が表示されていること',
                    total: expected[:total] || per_page,
                    from: expected[:from] || 1,
                    to: expected[:to] || per_page
    it_behaves_like 'ジョブ実行履歴を通知するテーブルが表示されていること',
                    columns: expected[:columns] || per_page
  end

  shared_examples '入力フォームが表示されていること' do
    form_xpath = '//form[@id="new_evaluation"]'

    %w[model from to].each do |param|
      input_xpath = "#{form_xpath}/div[@class='form-group']"

      it "evaluation_#{param}を含む<label>タグがあること" do
        label = @html.xpath("#{input_xpath}/label[@for='evaluation_#{param}']")
        is_asserted_by { label.present? }
      end

      it "evaluation_#{param}を含む<input>タグがあること" do
        input = @html.xpath("#{input_xpath}/input[@id='evaluation_#{param}']")
        is_asserted_by { input.present? }
      end
    end

    %w[submit reset].each do |type|
      it "typeが#{type}のボタンがあること" do
        button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
        is_asserted_by { button.present? }
      end
    end
  end

  shared_examples 'ジョブ実行履歴を通知するテーブルが表示されていること' do |columns: 0|
    table_xpath = '//table[@id="table-job"]'
    expected = {rows: 6, columns: columns, headers: %w[実行開始日時 モデル 期間 ペア Log損失 状態]}

    it_behaves_like 'テーブルが正しく表示されていること', table_xpath, expected
  end

  shared_examples 'ジョブの状態が正しいこと' do |state: nil, result: nil|
    before(:each) do
      @rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
    end

    it '実行開始日時が正しいこと' do
      @rows.each_with_index do |row, i|
        performed_at = row.children.search('td')[0].text.strip
        is_asserted_by do
          performed_at == @evaluations[i].performed_at&.strftime('%Y/%m/%d %T').to_s
        end
      end
    end

    it 'モデルが正しいこと' do
      @rows.each_with_index do |row, i|
        model = row.children.search('td')[1].text.strip
        is_asserted_by { model == @evaluations[i].model }
      end
    end

    it '期間が正しいこと' do
      @rows.each_with_index do |row, i|
        period = row.children.search('td')[2].text.strip.lines.map(&:chomp).map(&:strip)
        expected_from = "開始: #{@evaluations[i].from.strftime('%Y/%m/%d')}"
        expected_to = "終了: #{@evaluations[i].to.strftime('%Y/%m/%d')}"
        is_asserted_by { period.first == expected_from }
        is_asserted_by { period.last == expected_to }
      end
    end

    it 'ペアが正しいこと' do
      @rows.each_with_index do |row, i|
        pair = row.children.search('td')[3].text.strip
        is_asserted_by { pair == @evaluations[i].analysis.pair }
      end
    end

    it 'Log損失が正しいこと' do
      @rows.each_with_index do |row, i|
        log_loss = row.children.search('td')[4].text.strip
        is_asserted_by { log_loss == @evaluations[i].log_loss&.round(4).to_s }
      end
    end

    it '状態が正しいこと' do
      @rows.each_with_index do |row, i|
        state = row.children.search('td')[5].text.strip
        is_asserted_by { state == displayed_state[@evaluations[i].state] }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @evaluation = Evaluation.new
  end

  before(:each) do
    render template: 'evaluations/index', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', state: 'waiting'
  end

  context '実行中の場合' do
    param = {state: 'processing'}
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', attribute: default_attribute.merge(param)
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', param
  end

  context '完了している場合' do
    param = {state: 'completed'}
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', attribute: default_attribute.merge(param)
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', param
  end

  context 'エラーの場合' do
    param = {state: 'error'}
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', attribute: default_attribute.merge(param)
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', param
  end

  context "評価ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', total: total
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'evaluation'
  end
end
