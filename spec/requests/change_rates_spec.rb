# coding: utf-8
require 'rails_helper'

describe 'グラフを変更する', :type => :request, :js => true do
  shared_examples 'クエリが正しいこと' do |pair, interval|
    it { expect(current_url).to match /pair=#{pair}&interval=#{interval}/ }
  end

  describe 'ルートパスにアクセスする' do
    include_context '認証情報を入力する'
    before(:each) { visit '/' }
    it_behaves_like 'レート画面にリダイレクトされていること'
    it_behaves_like 'リンクの状態が正しいこと', 'rate'
    it_behaves_like 'セレクトボックスの状態が正しいこと', 'USDJPY', '5-min'
    it_behaves_like '表示されているデータが正しいこと', 'レート', 'rate'

    describe 'ペアを選択する' do
      before(:each) { select 'EURJPY', :from => 'pair' }
      it_behaves_like 'クエリが正しいこと', 'EURJPY', '5-min'
      it_behaves_like 'セレクトボックスの状態が正しいこと', 'EURJPY', '5-min'

      describe '期間を選択する' do
        before(:each) { select '10-min', :from => 'interval' }
        it_behaves_like 'クエリが正しいこと', 'EURJPY', '10-min'
        it_behaves_like 'セレクトボックスの状態が正しいこと', 'EURJPY', '10-min'
      end
    end
  end
end
