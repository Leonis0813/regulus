# -*- coding: utf-8 -*-

shared_context '分析ジョブを登録する' do |total: nil, update_attribute: {}|
  default_attribute = {
    from: 2.months.ago,
    to: 1.month.ago,
    pair: Analysis::PAIR_LIST.sample,
    batch_size: 100,
    state: 'processing',
  }

  before(:all) do
    attribute = default_attribute.merge(update_attribute)
    total ||= AnalysisViewHelper::DEFAULT_PER_PAGE
    total.times do |i|
      create(:analysis, attribute.merge(analysis_id: i.to_s * 32))
    end
    @analyses = Analysis.order(created_at: :desc).page(1)
  end
end

shared_examples '分析画面共通テスト' do |expected: {}|
  it_behaves_like 'ヘッダーが表示されていること'
  it_behaves_like '分析情報入力フォームが表示されていること'
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || AnalysisViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || AnalysisViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '分析ジョブテーブルが表示されていること',
                  columns: expected[:columns] || AnalysisViewHelper::DEFAULT_PER_PAGE
end

shared_examples '分析情報入力フォームが表示されていること' do
  form_xpath = '//form[@id="new_analysis"]'

  it '分析結果を確認するリンクが表示されていること' do
    span = @html.xpath('//div[@id="new-analysis"]/div/span[@id="analysis-result"]')
    is_asserted_by { span.present? }
    is_asserted_by { span.text == 'こちら' }
  end

  %w[from to pair batch_size].each do |param|
    input_xpath = "#{form_xpath}/div[@class='form-group']"

    it "analysis_#{param}を含む<label>タグがあること" do
      label = @html.xpath("#{input_xpath}/label[@for='analysis_#{param}']")
      is_asserted_by { label.present? }
    end

    it "analysis_#{param}を含む<input>タグがあること", unless: param == 'pair' do
      input = @html.xpath("#{input_xpath}/input[@id='analysis_#{param}']")
      is_asserted_by { input.present? }
    end

    it "analysis_#{param}を含む<select>タグがあること", if: param == 'pair' do
      select = @html.xpath("#{input_xpath}/select[@id='analysis_#{param}']")
      is_asserted_by { select.present? }
    end

    Analysis::PAIR_LIST.each do |pair|
      it "#{pair}を選択できること", if: param == 'pair' do
        select_xpath = "#{input_xpath}/select[@id='analysis_#{param}']"
        option = @html.xpath("#{select_xpath}/option[@value='#{pair}']")
        is_asserted_by { option.present? }
      end
    end

    it 'デフォルトでUSDJPYが選択されていること', if: param == 'pair' do
      select_xpath = "#{input_xpath}/select[@id='analysis_#{param}']"
      default_option = @html.xpath("#{select_xpath}/option[@value='USDJPY']")
      is_asserted_by { default_option.attribute('selected').value == 'selected' }
    end
  end

  %w[submit reset].each do |type|
    it "typeが#{type}のボタンがあること" do
      button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
      is_asserted_by { button.present? }
    end
  end
end

shared_examples '分析ジョブテーブルが表示されていること' do |columns: 0|
  table_xpath = "#{ViewHelper.table_panel_xpath}/table[@class='table table-hover']"
  expected = {rows: 6, columns: columns, headers: %w[実行開始日時 期間 ペア バッチサイズ 状態]}

  it_behaves_like 'テーブルが正しく表示されていること', table_xpath, expected

  it '再実行ボタンが配置されている列があること' do
    header_rebuild = @html.xpath("#{table_xpath}/thead/th[@class='rebuild']")
    is_asserted_by { header_rebuild.present? }
  end
end

shared_examples '分析ジョブの状態が正しいこと' do |state|
  before(:each) do
    @rows =
      @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
  end

  it 'ペアが正しいこと' do
    @rows.each_with_index do |row, i|
      displayed_pair = row.children.search('td')[2].text.strip
      is_asserted_by { displayed_pair == @analyses[i].pair }
    end
  end

  it '状態が正しいこと' do
    @rows.each do |row|
      is_asserted_by { row.xpath('//td')[4].text.strip == state }
    end
  end
end
