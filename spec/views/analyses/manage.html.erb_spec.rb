# coding: utf-8
require 'rails_helper'

describe 'analyses/manage', :type => :view do
  per_page = 1
  total_jobs = 10

  shared_context '分析ジョブを登録する' do |num|
    before(:all) do
      param = {:num_data => 10000, :interval => 10}
      num.times { Analysis.create!(param.merge(:state => %w[processing completed].sample)) }
      @analyses = Analysis.order(:created_at => :desc).page(1)
    end

    after(:all) { Analysis.destroy_all }
  end

  shared_examples '入力フォームが表示されていること' do
    form_xpath = '//form[@id="new_analysis"]'

    %w[ num_data interval ].each do |param|
      input_xpath = "#{form_xpath}/span[@class='input-custom']"

      it "analysis_#{param}を含む<label>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/label[for='analysis_#{param}']")
      end

      it "analysis_#{param}を含む<input>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/input[id='analysis_#{param}']")
      end
    end

    %w[ submit reset ].each do |type|
      it "typeが#{type}のボタンがあること" do
        expect(@html).to have_selector("#{form_xpath}/span[@class='pull-right']/input[type='#{type}']")
      end
    end
  end

  shared_examples 'ジョブ実行履歴が表示されていること' do |expected_size: per_page, total: 0, from: 1, to: 1|
    base_xpath = '/html/body'

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{base_xpath}/h3", :text => 'ジョブ実行履歴')
    end

    it '件数情報が表示されていること' do
      expect(@html).to have_selector("#{base_xpath}/h4", :text => "#{total}件中#{from}〜#{to}件を表示")
    end

    paging_xpath = "#{base_xpath}/div/nav/ul[@class='pagination']"

    it '先頭のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='first']/a"
      expect(@html).not_to have_selector(xpath, :text => I18n.t('views.list.pagination.first'))
    end

    it '前のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='prev']/a"
      expect(@html).not_to have_selector(xpath, :text => I18n.t('views.list.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item active']"
      expect(@html).to have_selector(xpath, :text => 1)
    end

    it '2ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/a[href='/analyses?page=2']"
      expect(@html).to have_selector(xpath, :text => 2)
    end

    it '次のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='next']/a[href='/analyses?page=2']"
      expect(@html).to have_selector(xpath, :text => I18n.t('views.pagination.next'))
    end

    it '最後のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='last']/a"
      expect(@html).to have_selector(xpath, :text => I18n.t('views.pagination.last'))
    end

    %w[ 実行開始日時 学習データ数 予測先(期間) 状態 ].each do |header|
      it "ヘッダー(#{header})があること" do
        xpath = "#{base_xpath}/div/table[@class='table table-hover']/thead/th"
        expect(@html).to have_selector(xpath, :text => header)
      end
    end

    it 'データの数が正しいこと' do
      xpath = "#{base_xpath}/div/table[@class='table table-hover']/tbody/tr"
      expect(@html).to have_xpath(xpath, :count => expected_size)
    end

    it '背景色が正しいこと', :if => expected_size > 0 do
      matched_data = @html.gsub("\n", '').match(/<tr\s*class='(?<color>.*?)'\s*>(?<data>.*?)<\/tr>/)
      case matched_data[:color]
      when 'warning'
        is_asserted_by { matched_data[:data].include?('実行中') }
      when 'success'
        is_asserted_by { matched_data[:data].include?('完了') }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @analysis = Analysis.new
  end

  before(:each) do
    render :template => 'analyses/manage', :layout => 'layouts/application'
    @html ||= response
  end

  describe '<html><body>' do
    include_context '分析ジョブを登録する', total_jobs
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like 'ジョブ実行履歴が表示されていること', {:total => total_jobs}
  end
end
