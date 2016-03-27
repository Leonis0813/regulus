# coding: utf-8
require 'rails_helper'

describe '通貨情報を確認する', :type => :request do
  include_context '共通設定'

  describe 'ルートパスにアクセスする' do
    before(:all) do
      @res = @hc.get("#{@base_url}/")
    end

    it 'レート画面にリダイレクトされること' do
      expect(@res.headers['Location']).to eq("#{@base_url}/rates")
    end

    describe 'リダイレクト先へアクセスする' do
      before(:all) do
        encoded_key = Base64::encode64("dev:.dev")
        @hc.set_auth(@res.headers['Location'], 'dev', '.dev');
        @res = @hc.get(@res.headers['Location'])
      end

      it 'アクセスできること' do
        expect(@res.code).to eq(200)
      end

      describe 'ツイートを表示する' do
        before(:all) do
          @res = @hc.get("#{@base_url}/tweets")
        end

        it 'アクセスできること' do
          expect(@res.code).to eq(200)          
        end
      end
    end
  end
end
