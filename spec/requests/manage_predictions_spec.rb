# coding: utf-8

require 'rails_helper'

describe 'ブラウザで予測する', type: :request do
  include_context 'WebDriverを起動してCookieをセットする'

  describe '予測画面を開く' do
    before(:all) { @driver.get("#{base_url}/predictions") }

    it '予測画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/predictions" }
      is_asserted_by { @driver.find_element(:id, 'prediction_model') }
      is_asserted_by { @driver.find_element(:xpath, '//form/input[@value="実行"]') }
    end

    describe '定期予測の設定を行う' do
      before(:all) do
        @wait.until do
          res = @driver.find_element(:xpath, '//a[text()="設定"]').click rescue false
          res.nil? ? true : false
        end

        xpath = '//input[@id="auto_status_inactive"]'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end

        xpath = '//form[@id="setting"]/input[@value="実行"]'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end
      end

      it 'ジョブ登録フォームに戻っていること' do
        xpath = '//li[@class="active"]/a[text()="ジョブ登録"]'
        is_asserted_by { @wait.until { @driver.find_element(:xpath, xpath) } }
      end
    end
  end
end
