# -*- coding: utf-8 -*-

shared_context '評価ジョブを登録する' do |total: nil, update_attribute: {}|
  default_attribute = {model: 'analysis.zip', from: '1000-01-01', to: '1000-01-31'}

  before(:all) do
    analysis = create(:analysis, pair: Analysis::PAIR_LIST.sample)

    attribute = default_attribute.merge(update_attribute)
    total ||= EvaluationViewHelper::DEFAULT_PER_PAGE
    total.times do |i|
      attribute[:evaluation_id] = i.to_s * 32
      create(:evaluation, attribute.merge(analysis: analysis))
    end
    @evaluations = Evaluation.order(created_at: :desc).page(1)
  end
end

shared_examples '評価画面共通テスト' do |expected: {}|
  it_behaves_like 'ヘッダーが表示されていること'
  it_behaves_like '評価情報入力フォームが表示されていること', expected[:configs] || []
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || EvaluationViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || EvaluationViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '評価ジョブテーブルが表示されていること',
                  columns: expected[:columns] || EvaluationViewHelper::DEFAULT_PER_PAGE
end

shared_examples '評価情報入力フォームが表示されていること' do
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

shared_examples '評価ジョブテーブルが表示されていること' do |columns: 0|
  table_xpath = '//table[@id="table-job"]'
  expected = {rows: 6, columns: columns, headers: %w[実行開始日時 モデル 期間 ペア Log損失 状態]}

  it_behaves_like 'テーブルが正しく表示されていること', table_xpath, expected
end

shared_examples '評価ジョブの状態が正しいこと' do
  displayed_state = {
    'waiting' => '実行待ち',
    'processing' => '実行中',
    'completed' => '完了',
    'error' => 'エラー',
  }

  before do
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
