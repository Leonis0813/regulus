# coding: utf-8

require 'rails_helper'

describe 'analyses/manage', type: :view do
  per_page = 1
  default_attribute = {
    from: 2.months.ago,
    to: 1.month.ago,
    pair: Analysis::PAIR_LIST.sample,
    batch_size: 100,
    state: 'processing',
  }

  shared_context '分析ジョブを登録する' do |total: per_page, attribute: default_attribute|
    before(:all) do
      total.times { Analysis.create!(attribute) }
      @analyses = Analysis.order(created_at: :desc).page(1)
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
                    columns: expected[:columns] || per_page
  end

  shared_examples '入力フォームが表示されていること' do
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

  shared_examples 'テーブルが表示されていること' do |columns: 0|
    table_xpath = "#{ViewHelper.table_panel_xpath}/table[@class='table table-hover']"

    it_behaves_like 'テーブルが正しく表示されていること', table_xpath, {
      row_size: 6,
      column_size: columns,
      headers: %w[実行開始日時 期間 ペア バッチサイズ 状態],
    }

    it '再実行ボタンが配置されている列があること' do
      header_rebuild = @html.xpath("#{table_xpath}/thead/th[@class='rebuild']")
      is_asserted_by { header_rebuild.present? }
    end
  end

  shared_examples 'ジョブの状態が正しいこと' do |state|
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

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @analysis = Analysis.new
  end

  before(:each) do
    render template: 'analyses/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行中の場合' do
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行中'
  end

  context '完了しているの場合' do
    attribute = default_attribute.merge(state: 'completed')
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する', attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '完了'
  end

  context 'エラーの場合' do
    attribute = default_attribute.merge(state: 'error')
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する', attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', 'エラー'
  end

  context "分析ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する', total: total
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'analysis'
  end
end
