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
          res = @driver.find_element(:id, 'btn-prediction-setting').click rescue false
          res.nil? ? true : false
        end

        xpath = '//button[@data-bb-handler="ok"]'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end
      end

      after(:all) do
        xpath = '//button[@data-bb-handler="ok"]'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end
      end

      it '成功時のダイアログのタイトルが正しいこと' do
        xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
        text = 'モデルを設定しました'
        is_asserted_by do
          @wait.until { @driver.find_element(:xpath, xpath).text == text rescue false }
        end
      end

      it '成功時のダイアログのメッセージが正しいこと' do
        xpath = '//div[@class="modal-body"]/div'
        text = '次の予測から設定したモデルが利用されます'
        is_asserted_by do
          @wait.until { @driver.find_element(:xpath, xpath).text == text rescue false }
        end
      end
    end
  end
end
