# coding: utf-8
require 'rails_helper'

describe '通貨情報を確認する', :type => :request do
  shared_examples 'アクセスできること' do
    it { expect(@res.code).to eq(200) }
  end

  shared_examples 'タブが表示されていること' do
    it { expect(@res.body).to match /a.*href="\/rates"/ }
    it { expect(@res.body).to match /a.*href="\/tweets"/ }
    it { expect(@res.body).to match /a.*href="\/articles"/ }
  end

  shared_examples '表示されているデータが正しいこと' do |resource|
    it { expect(@res.body).to match /div.*id="#{resource}"/ }
    it { expect(@res.body).to match /a.*href="\/#{resource}s".*class="selected"/ }
  end

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
      it_behaves_like '表示されているデータが正しいこと', 'rate'

      describe 'ツイートを表示する' do
        before(:all) { @res = @hc.get("#{@base_url}/tweets") }

        it_behaves_like 'アクセスできること'
        it_behaves_like 'タブが表示されていること'
        it_behaves_like '表示されているデータが正しいこと', 'tweet'

        describe '記事を表示する' do
          before(:all) { @res = @hc.get("#{@base_url}/articles") }

          it_behaves_like 'アクセスできること'
          it_behaves_like 'タブが表示されていること'
          it_behaves_like '表示されているデータが正しいこと', 'article'
        end
      end
    end
  end
end
