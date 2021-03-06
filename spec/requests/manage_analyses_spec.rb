# coding: utf-8

require 'rails_helper'

describe 'ブラウザで分析する', type: :request do
  include_context 'WebDriverを起動してCookieをセットする'

  describe '分析画面を開く' do
    before(:all) { @driver.get("#{base_url}/analyses") }

    it '分析画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/analyses" }
    end
  end

  describe '不正な値を入力する' do
    before(:all) do
      from = @driver.find_element(:id, 'analysis_from')
      from.clear
      from.send_keys('invalid')
      to = @driver.find_element(:id, 'analysis_to')
      to.clear
      to.send_keys('invalid')
      pair = @driver.find_element(:id, 'analysis_pair')
      Selenium::WebDriver::Support::Select.new(pair).select_by(:value, 'EURJPY')
      @driver.find_element(:id, 'analysis_batch_size').send_keys(1)
      @driver.find_element(:xpath, '//form/input[@value="実行"]').click
      @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
    end

    it 'タイトルが正しいこと' do
      xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
      text = 'エラーが発生しました'
      is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
    end

    it 'エラーメッセージが正しいこと' do
      xpath = '//div[@class="modal-body"]/div'
      text = '入力値を見直してください'
      is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
    end
  end

  describe '分析を実行する' do
    before(:all) do
      @driver.get("#{base_url}/analyses")
      from = @driver.find_element(:id, 'analysis_from')
      from.clear
      from.send_keys('2000-01-01 00:00:00')
      to = @driver.find_element(:id, 'analysis_to')
      to.clear
      to.send_keys('2000-01-10 23:59:59')
      @driver.find_element(:id, 'analysis_batch_size').send_keys(100)
      @driver.find_element(:xpath, '//form/input[@value="実行"]').click
      @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
    end

    it 'タイトルが正しいこと' do
      xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
      text = '分析を開始しました'
      is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
    end

    it 'メッセージが正しいこと' do
      xpath = '//div[@class="modal-body"]/div'
      text = '終了後、メールにて結果を通知します'
      is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
    end
  end
end
