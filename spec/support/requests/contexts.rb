# coding: utf-8

shared_context '認証情報を入力する' do
  before(:each) { page.driver.browser.authenticate('dev', '.dev') }
end
