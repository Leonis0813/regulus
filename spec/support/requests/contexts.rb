# coding: utf-8

shared_context '認証情報を入力する' do
  before(:all) { page.driver.browser.authorize('dev', '.dev') }
end
