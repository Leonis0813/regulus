# coding: utf-8
require 'rails_helper'

describe '通貨情報を確認する', :type => :request, :js => true do
  describe 'ルートパスにアクセスする' do
    include_context '認証情報を入力する'
    before(:each) { visit '/' }
    it_behaves_like 'レート画面にリダイレクトされていること'
    it_behaves_like 'リンクの状態が正しいこと', 'rate'
    it_behaves_like 'セレクトボックスの状態が正しいこと', 'USDJPY', '5-min'
    it_behaves_like '表示されているデータが正しいこと', 'レート', 'div#rate'

    describe 'ツイートを表示する' do
      before(:each) { click_link 'ツイート' }
      it_behaves_like 'リンクの状態が正しいこと', 'tweet'
      it_behaves_like '表示されているデータが正しいこと', 'ツイート', 'tbody#tweet'

      describe '記事を表示する' do
        before(:each) { click_link '記事' }
        it_behaves_like 'リンクの状態が正しいこと', 'article'
        it_behaves_like '表示されているデータが正しいこと', '記事', 'tbody#article'
      end

      describe 'レートを表示する' do
        before(:each) { click_link 'レート' }
        it_behaves_like 'リンクの状態が正しいこと', 'rate'
        it_behaves_like 'セレクトボックスの状態が正しいこと', 'USDJPY', '5-min'
        it_behaves_like '表示されているデータが正しいこと', 'レート', 'div#rate'
      end
    end
  end
end
