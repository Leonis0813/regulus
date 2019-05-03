# coding: utf-8
require 'rails_helper'

describe 'predictions/manage', type: :view do
  per_page = 1

  shared_context '予測ジョブを登録する' do |num|
    before(:all) do
      num.times do
        prediction = Prediction.new(model: 'analysis.zip', state: %w[ processing completed ].sample)
        prediction.result = %w[ up down range ].sample if prediction.state == 'completed'
        prediction.save!
      end
      @predictions = Prediction.order(created_at: :desc).page(1)
    end

    after(:all) do
      Prediction.destroy_all
    end
  end

  shared_examples '入力フォームが表示されていること' do
    form_xpath = '//form[@id="new_prediction"]'

    %w[ model ].each do |param|
      input_xpath = "#{form_xpath}/div[@class='form-group']"

      it "prediction_#{param}を含む<label>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/label[for='prediction_#{param}']")
      end

      it "prediction_#{param}を含む<input>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/input[id='prediction_#{param}']")
      end
    end

    %w[ submit reset ].each do |type|
      it "typeが#{type}のボタンがあること" do
        expect(@html).to have_selector("#{form_xpath}/input[type='#{type}']")
      end
    end
  end

  shared_examples 'ジョブ実行履歴が表示されていること' do |expected_size: per_page, total: 0, from: 1, to: 1|
    base_xpath = '/html/body/div[@id="main-content"]/div[@class="row center-block"]/div[@class="col-lg-8"]'

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{base_xpath}/h4", text: 'ジョブ実行履歴')
    end

    it '件数情報が表示されていること' do
      expect(@html).to have_selector("#{base_xpath}/h4", text: "#{total}件中#{from}〜#{to}件を表示")
    end

    paging_xpath = "#{base_xpath}/nav/ul[@class='pagination']"

    it '先頭のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='first']/a"
      expect(@html).not_to have_selector(xpath, text: I18n.t('views.list.pagination.first'))
    end

    it '前のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='prev']/a"
      expect(@html).not_to have_selector(xpath, text: I18n.t('views.list.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item active']"
      expect(@html).to have_selector(xpath, text: 1)
    end

    it '2ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/a[href='/predictions?page=2']"
      expect(@html).to have_selector(xpath, text: 2)
    end

    it '次のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='next']/a[href='/predictions?page=2']"
      expect(@html).to have_selector(xpath, text: I18n.t('views.pagination.next'))
    end

    it '最後のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='last']/a"
      expect(@html).to have_selector(xpath, text: I18n.t('views.pagination.last'))
    end

    %w[ 実行開始日時 モデル 期間 結果 ].each do |header|
      it "ヘッダー(#{header})があること" do
        xpath = "#{base_xpath}/table[@class='table table-hover']/thead/th"
        expect(@html).to have_selector(xpath, text: header)
      end
    end

    it 'データの数が正しいこと' do
      xpath = "#{base_xpath}/table[@class='table table-hover']/tbody/tr"
      expect(@html).to have_xpath(xpath, count: expected_size)
    end

    it '背景色と結果が正しいこと', if: expected_size > 0 do
      row = @html.gsub("\n", '').scan(/<tr.*?tr>/).first

      is_asserted_by do
        row.match(/warning.*question-sign/) or row.match(/success.*arrow-(up|down|right)/)
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @prediction = Prediction.new
  end

  before(:each) do
    render template: 'predictions/manage', layout: 'layouts/application'
    @html ||= response
  end

  describe '<html><body>' do
    include_context '予測ジョブを登録する', 10
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like 'ジョブ実行履歴が表示されていること',
                      expected_size: 1,
                      total: 10,
                      from: 1,
                      to: 1,
  end
end
