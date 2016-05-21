# coding: utf-8
require 'rails_helper'

describe '通貨情報を確認する', :type => :request do
  shared_examples 'リンクの状態が正しいこと' do |selected_link|
    [['レート', '/rates'], ['ツイート', '/tweets'], ['記事', '/articles']].each do |text, path|
      it "'#{text}'へのリンクが表示されていること" do
        condition = path.match(/#{selected_link}/) ? 'selected' : 'not-selected'
        expect(page).to have_selector("a[href='#{path}'][class='#{condition}']", :text => text)
      end
    end
  end

  shared_examples 'セレクトボックスの状態が正しいこと' do |pair, interval|
    [pair, interval].each do |selected|
      it { expect(page).to have_xpath("//form/select/option[text()='#{selected}'][@selected]") }
    end
  end

  shared_examples '表示されているデータが正しいこと' do |content, id|
    it "#{content}が表示されていること" do
      expect(page).to have_selector("div##{id}")
    end
  end

  describe 'ルートパスにアクセスする' do
    before(:all) do
      page.driver.browser.authorize('dev', '.dev')
      visit '/'
    end

    it 'レート画面にリダイレクトされていること' do
      expect(current_url).to eq("#{Capybara.app_host}/rates")
    end

    it_behaves_like 'リンクの状態が正しいこと', 'rate'
    it_behaves_like 'セレクトボックスの状態が正しいこと', 'USDJPY', '5-min'
    it_behaves_like '表示されているデータが正しいこと', 'レート', 'rate'

    describe 'ツイートを表示する' do
      before(:all) { click_link 'ツイート' }
      it_behaves_like 'リンクの状態が正しいこと', 'tweet'
      it_behaves_like '表示されているデータが正しいこと', 'ツイート', 'tweet'

      describe '記事を表示する' do
        before(:all) { click_link '記事' }
        it_behaves_like 'リンクの状態が正しいこと', 'article'
        it_behaves_like '表示されているデータが正しいこと', '記事', 'article'
      end

      describe 'レートを表示する' do
        before(:all) { click_link 'レート' }
        it_behaves_like 'リンクの状態が正しいこと', 'rate'
        it_behaves_like 'セレクトボックスの状態が正しいこと', 'USDJPY', '5-min'
        it_behaves_like '表示されているデータが正しいこと', 'レート', 'rate'
      end
    end
  end
end
