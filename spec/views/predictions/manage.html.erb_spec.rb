# coding: utf-8

require 'rails_helper'

describe 'predictions/manage', type: :view do
  per_page = 1
  default_attribute = {
    model: 'analysis.zip',
    pair: Prediction::PAIR_LIST.sample,
    state: 'processing',
  }
  means = {
    'manual' => '手動',
    'auto' => '自動',
  }
  icon_class = {
    'processing' => 'question-sign',
    'error' => 'remove',
    'completed' => {
      'up' => 'circle-arrow-up',
      'down' => 'circle-arrow-down',
      'range' => 'circle-arrow-right',
    },
  }
  icon_color = {
    'processing' => 'black',
    'error' => 'red',
    'completed' => {
      'up' => 'blue',
      'down' => 'red',
      'range' => 'orange',
    },
  }

  shared_context '予測ジョブを登録する' do |total: per_page, attribute: default_attribute|
    before(:all) do
      total.times { Prediction.create!(attribute) }
      @predictions = Prediction.order(created_at: :desc).page(1)
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like '表示件数情報が表示されていること',
                    total: expected[:total] || per_page,
                    from: expected[:from] || 1,
                    to: expected[:to] || per_page
    it_behaves_like 'テーブルが表示されていること',
                    rows: expected[:rows] || per_page
  end

  shared_examples '入力フォームが表示されていること' do
    form_xpath = '//form[@id="new_prediction"]'

    it '設定ボタンが表示されていること' do
      xpath = [
        row_xpath,
        'div[@class="col-lg-4"]',
        'div[@id="new-prediction"]',
        'div/button[@id="btn-prediction-setting"]',
      ].join('/')
      is_asserted_by { @html.xpath(xpath).present? }
    end

    %w[model].each do |param|
      input_xpath = "#{form_xpath}/div[@class='form-group']"

      it "prediction_#{param}を含む<label>タグがあること" do
        label = @html.xpath("#{input_xpath}/label[@for='prediction_#{param}']")
        is_asserted_by { label.present? }
      end

      it "prediction_#{param}を含む<input>タグがあること" do
        input = @html.xpath("#{input_xpath}/input[@id='prediction_#{param}']")
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

  shared_examples 'テーブルが表示されていること' do |rows: 0|
    before(:each) do
      @table = @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']")
    end

    it '6列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 6 }
    end

    %w[実行開始日時 モデル 期間 ペア 方法 結果].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples 'ジョブの状態が正しいこと' do |state: nil, result: nil|
    before(:each) do
      @rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
    end

    it 'ペアが正しいこと' do
      @rows.each_with_index do |row, i|
        displayed_pair = row.children.search('td')[3].text.strip
        is_asserted_by { displayed_pair == @predictions[i].pair }
      end
    end

    it '方法が正しいこと' do
      @rows.each_with_index do |row, i|
        displayed_means = row.children.search('td')[4].text.strip
        is_asserted_by { displayed_means == means[@predictions[i].means] }
      end
    end

    it 'アイコンが正しいこと' do
      @rows.each do |row|
        glyphicon_name = result ? icon_class[state][result] : icon_class[state]
        span_class = "glyphicon glyphicon-#{glyphicon_name}"
        icon = row.children.search('td')[5].children
                  .search("span[@class='#{span_class}']")
        is_asserted_by { icon.present? }
      end
    end

    it 'アイコンの色が正しいこと' do
      @rows.each do |row|
        glyphicon_color = result ? icon_color[state][result] : icon_color[state]
        color = row.children.search('td')[5].children.search('span').attribute('style')
        is_asserted_by { color.value == "color: #{glyphicon_color}" }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @prediction = Prediction.new
  end

  before(:each) do
    render template: 'predictions/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行中の場合' do
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', state: 'processing'
  end

  context '完了している場合' do
    context '予測結果が上昇の場合' do
      param = {state: 'completed', result: 'up'}
      include_context 'トランザクション作成'
      include_context '予測ジョブを登録する', attribute: default_attribute.merge(param)
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブの状態が正しいこと', param
    end

    context '予測結果が下降の場合' do
      param = {state: 'completed', result: 'down'}
      include_context 'トランザクション作成'
      include_context '予測ジョブを登録する', attribute: default_attribute.merge(param)
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブの状態が正しいこと', param
    end

    context '予測結果がレンジの場合' do
      param = {state: 'completed', result: 'range'}
      include_context 'トランザクション作成'
      include_context '予測ジョブを登録する', attribute: default_attribute.merge(param)
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブの状態が正しいこと', param
    end
  end

  context 'エラーの場合' do
    param = {state: 'error'}
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する', attribute: default_attribute.merge(param)
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', state: 'error'
  end

  context '自動実行の場合' do
    param = {means: 'auto'}
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する', attribute: default_attribute.merge(param)
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', state: 'processing'
  end

  context "予測ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する', total: total
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'prediction'
  end
end
