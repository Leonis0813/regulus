# -*- coding: utf-8 -*-

shared_context '予測ジョブを登録する' do |total: nil, update_attribute: {}|
  default_attribute = {
    model: 'analysis.zip',
    state: 'processing',
  }

  before(:all) do
    analysis = create(:analysis, pair: Analysis::PAIR_LIST.sample)

    attribute = default_attribute.merge(update_attribute)
    total ||= PredictionViewHelper::DEFAULT_PER_PAGE
    total.times { create(:prediction, attribute.merge(analysis: analysis)) }
    @predictions = Prediction.order(created_at: :desc).page(1)
  end
end

shared_examples '予測画面共通テスト' do |expected: {}|
  it_behaves_like 'ヘッダーが表示されていること'
  it_behaves_like '予測情報入力フォームが表示されていること', expected[:configs] || []
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || PredictionViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || PredictionViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '予測ジョブ実行履歴を通知するテーブルが表示されていること',
                  columns: expected[:columns] || PredictionViewHelper::DEFAULT_PER_PAGE
end

shared_examples '予測情報入力フォームが表示されていること' do |configs|
  [
    %w[prediction ジョブ登録],
    %w[setting 設定],
  ].each do |href, text|
    it "#{text}のタブが表示されていること" do
      xpath = [
        row_xpath,
        'div[@class="col-lg-4"]',
        'ul[@class="nav nav-tabs"]',
        'li',
        "a[@href='#tab-#{href}']",
      ].join('/')
      is_asserted_by { @html.xpath(xpath).present? }
      is_asserted_by { @html.xpath(xpath).text == text }
    end
  end

  it_behaves_like '予測ジョブ登録用のフォームが表示されていること'
  it_behaves_like '自動予測設定用のフォームが表示されていること', configs
end

shared_examples '予測ジョブ登録用のフォームが表示されていること' do
  form_xpath = '//form[@id="new_prediction"]'

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

shared_examples '自動予測設定用のフォームが表示されていること' do |configs|
  form_xpath = '//form[@id="setting"]'

  %w[auto_status_active auto_status_inactive].each do |status|
    input_xpath = "#{form_xpath}/div[@class='form-group']"

    it "#{status}を含む<label>タグがあること" do
      label = @html.xpath("#{input_xpath}/label[@for='#{status}']")
      is_asserted_by { label.present? }
    end

    it "#{status}を含む<input>タグがあること" do
      input = @html.xpath("#{input_xpath}/input[@id='#{status}']")
      is_asserted_by { input.present? }
    end
  end

  it 'モデルを設定するフォームがあること' do
    base_xpath = [form_xpath, 'div[@id="form-active"]'].join('/')
    label_xpath = [base_xpath, 'label[@for="auto_model"]'].join('/')
    is_asserted_by { @html.xpath(label_xpath).present? }

    input_xpath = [base_xpath, 'input[@id="auto_model"]'].join('/')
    is_asserted_by { @html.xpath(input_xpath).present? }
  end

  it 'ペアを選択するフォームがあること' do
    base_xpath = [form_xpath, 'div[@id="form-inactive"]'].join('/')
    label_xpath = [base_xpath, 'label[@for="auto_pair"]'].join('/')
    is_asserted_by { @html.xpath(label_xpath).present? }

    select_xpath = [base_xpath, 'select[@id="auto_pair"]'].join('/')
    is_asserted_by { @html.xpath(select_xpath).present? }

    Settings.pairs.each do |pair|
      xpath = [select_xpath, "option[@value='#{pair}']"].join('/')
      is_asserted_by { @html.xpath(xpath).present? }
    end
  end

  %w[submit reset].each do |type|
    it "typeが#{type}のボタンがあること" do
      button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
      is_asserted_by { button.present? }
    end
  end

  it_behaves_like '現在の予測設定を通知するテーブルが表示されていること'
  it_behaves_like '予測設定の状態が正しいこと', configs
end

shared_examples '現在の予測設定を通知するテーブルが表示されていること' do
  table_xpath = '//table[@id="table-setting"]'
  expected = {rows: 2, columns: Settings.pairs.size, headers: %w[ペア 状態]}

  it_behaves_like 'テーブルが正しく表示されていること', table_xpath, expected
end

shared_examples '予測設定の状態が正しいこと' do |configs|
  status_to_class_map = {'active' => 'success', 'inactive' => 'danger'}
  status_to_text_map = {'active' => '有効', 'inactive' => '無効'}

  it do
    @html.xpath('//table[@id="table-setting"]/tbody/tr').each do |column|
      pair, status = column.children.search('td').map(&:text)
      tr_class = column.attribute('class').value

      target_config = configs.find {|config| config['pair'] == pair }
      target_config ||= {'status' => 'inactive'}

      is_asserted_by { status == status_to_text_map[target_config['status']] }
      is_asserted_by { tr_class == status_to_class_map[target_config['status']] }
    end
  end
end

shared_examples '予測ジョブ実行履歴を通知するテーブルが表示されていること' do |columns: 0|
  table_xpath = '//table[@id="table-job"]'
  expected = {rows: 6, columns: columns, headers: %w[実行開始日時 モデル 期間 ペア 方法 結果]}

  it_behaves_like 'テーブルが正しく表示されていること', table_xpath, expected
end

shared_examples '予測ジョブの状態が正しいこと' do |state: nil, result: nil|
  means = {'manual' => '手動', 'auto' => '自動'}
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

  before do
    @rows =
      @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
  end

  it 'ペアが正しいこと' do
    @rows.each_with_index do |row, i|
      displayed_pair = row.children.search('td')[3].text.strip
      is_asserted_by { displayed_pair == @predictions[i].analysis.pair }
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
      glyphicon_color = result ? icon_color[state][result] : icon_color[state]
      span_class = "glyphicon glyphicon-#{glyphicon_name} glyphicon-#{glyphicon_color}"
      icon = row.children.search('td')[5].children
                .search("span[@class='#{span_class}']")
      is_asserted_by { icon.present? }
    end
  end
end
