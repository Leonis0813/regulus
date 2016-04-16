# coding: utf-8
require 'rails_helper'

shared_examples 'アクセスできること' do
  it { expect(@res.code).to eq(200) }
end

shared_examples 'タブが表示されていること' do
  it { expect(@res.body).to match /a.*href="\/rates"/ }
  it { expect(@res.body).to match /a.*href="\/tweets"/ }
  it { expect(@res.body).to match /a.*href="\/articles"/ }
end

describe '通貨情報を確認する', :type => :request do
  include_context '共通設定'

  describe 'ルートパスにアクセスする' do
    before(:all) { @res = @hc.get("#{@base_url}/") }

    it 'レート画面にリダイレクトされること' do
      expect(@res.headers['Location']).to eq("#{@base_url}/rates")
    end

    describe 'リダイレクト先へアクセスする' do
      before(:all) do
        encoded_key = Base64::encode64("dev:.dev")
        @hc.set_auth(@res.headers['Location'], 'dev', '.dev');
        @res = @hc.get(@res.headers['Location'])
      end

      it_behaves_like 'アクセスできること'
      it_behaves_like 'タブが表示されていること'

      it 'グラフが表示されていること' do
        expect(@res.body).to match /div.*id="rate"/
      end

      it 'レートのタブが選択されていること' do
        expect(@res.body).to match /a.*href="\/rates".*class="selected"/
      end

      describe 'ツイートを表示する' do
        before(:all) { @res = @hc.get("#{@base_url}/tweets") }

        it_behaves_like 'アクセスできること'
        it_behaves_like 'タブが表示されていること'

        it 'ツイートが表示されていること' do
          expect(@res.body).to match /div.*id="tweet"/
        end

        it 'ツイートのタブが選択されていること' do
          expect(@res.body).to match /a.*href="\/tweets".*class="selected"/
        end

        describe '記事を表示する' do
          before(:all) { @res = @hc.get("#{@base_url}/articles") }

          it_behaves_like 'アクセスできること'
          it_behaves_like 'タブが表示されていること'

          it '記事が表示されていること' do
            expect(@res.body).to match /div.*id="article"/
          end

          it '記事のタブが選択されていること' do
            expect(@res.body).to match /a.*href="\/articles".*class="selected"/
          end
        end
      end
    end
  end
end
