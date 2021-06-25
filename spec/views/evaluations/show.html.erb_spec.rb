# coding: utf-8

require 'rails_helper'

describe 'evaluations/show', type: :view do
  main_content_xpath = '//div[@id="main-content"]'
  table_xpath = [
    main_content_xpath,
    'div[@class="well"]',
    'table[@id="table-evaluation-test-datum"]',
  ].join('/')
  icon_class = {
    up: 'glyphicon glyphicon-circle-arrow-up glyphicon-blue',
    down: 'glyphicon glyphicon-circle-arrow-down glyphicon-red',
  }

  shared_context '評価データを登録する' do |up: nil, down: nil, ground_truth: 'up'|
    before(:all) do
      @evaluation = create(:evaluation, log_loss: 0.2)
      @evaluation.test_data.create!(
        from: '1000-01-01',
        to: '1000-01-31',
        up_probability: up,
        down_probability: down,
        ground_truth: ground_truth,
      )
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like 'テーブルが表示されていること'

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{main_content_xpath}/div[@class='well']/h3").text.strip
      is_asserted_by { title == '評価結果詳細' }
    end

    it 'Log損失表示領域があること' do
      log_loss = @html.xpath("#{main_content_xpath}/div[@class='well']/h4").text.strip
      is_asserted_by { log_loss == "Log損失: #{@evaluation.log_loss&.round(4)}" }
    end
  end

  shared_examples 'テーブルが表示されていること' do
    before { @table = @html.xpath(table_xpath) }

    it '4列のテーブルが表示されていること' do
      is_asserted_by { @table.children.search('th').children.size == 4 }
    end

    %w[No 期間 予測結果 正解].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.children.search('th').children[i].text == text }
      end
    end

    it '予測結果の数が正しいこと' do
      is_asserted_by { @table.search('tbody/tr').size == 1 }
    end
  end

  shared_examples '予測結果の行のデザインが正しいこと' do |expected_class|
    before { @rows = @html.xpath("#{table_xpath}/tbody/tr") }

    it '行の色が正しいこと' do
      @rows.each do |row|
        is_asserted_by { row.attribute('class').value == expected_class[:tr].to_s }
      end
    end

    it 'Noが正しいこと' do
      @rows.each_with_index do |row, i|
        is_asserted_by { row.children.search('td')[0].text.strip == (i + 1).to_s }
      end
    end

    it '期間が正しいこと' do
      @rows.each do |row|
        period = row.children.search('td')[1].text.strip
        is_asserted_by { period == '1000/01/01 〜 1000/01/31' }
      end
    end

    show_prediction_result = expected_class[:prediction_result].present?

    it '予測結果のアイコンが表示されていないこと', unless: show_prediction_result do
      @rows.each do |row|
        icon = row.children.search('td')[2].children.search('span')
        is_asserted_by { not icon.present? }
      end
    end

    it '予測結果のアイコンが正しく表示されていること', if: show_prediction_result do
      @rows.each do |row|
        icon = row.children.search('td')[2].children.search('span').first
        is_asserted_by do
          icon.attribute('class').value == expected_class[:prediction_result]
        end
      end
    end

    it '正解のアイコンが正しく表示されていること' do
      @rows.each do |row|
        icon = row.children.search('td')[3].children.search('span').first
        is_asserted_by do
          icon.attribute('class').value == expected_class[:ground_truth]
        end
      end
    end
  end

  before(:each) do
    render template: 'evaluations/show', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    expected_class = {ground_truth: icon_class[:up]}
    include_context 'トランザクション作成'
    include_context '評価データを登録する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと', expected_class
  end

  context '予測が完了している場合' do
    context '予測結果: up, 正解: upの場合' do
      param = {up: 0.9, down: 0.1, ground_truth: 'up'}
      expected_class = {
        tr: 'success',
        prediction_result: icon_class[:up],
        ground_truth: icon_class[:up],
      }
      include_context 'トランザクション作成'
      include_context '評価データを登録する', param
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like '予測結果の行のデザインが正しいこと', expected_class
    end

    context '予測結果: up, 正解: downの場合' do
      param = {up: 0.9, down: 0.1, ground_truth: 'down'}
      expected_class = {
        tr: 'danger',
        prediction_result: icon_class[:up],
        ground_truth: icon_class[:down],
      }
      include_context 'トランザクション作成'
      include_context '評価データを登録する', param
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like '予測結果の行のデザインが正しいこと', expected_class
    end

    context '予測結果: down, 正解: upの場合' do
      param = {up: 0.1, down: 0.9, ground_truth: 'up'}
      expected_class = {
        tr: 'danger',
        prediction_result: icon_class[:down],
        ground_truth: icon_class[:up],
      }
      include_context 'トランザクション作成'
      include_context '評価データを登録する', param
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like '予測結果の行のデザインが正しいこと', expected_class
    end

    context '予測結果: down, 正解: downの場合' do
      param = {up: 0.1, down: 0.9, ground_truth: 'down'}
      expected_class = {
        tr: 'success',
        prediction_result: icon_class[:down],
        ground_truth: icon_class[:down],
      }
      include_context 'トランザクション作成'
      include_context '評価データを登録する', param
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like '予測結果の行のデザインが正しいこと', expected_class
    end
  end
end
