# coding: utf-8
require 'rails_helper'

describe "tweets/show", :type => :view do
  include_context 'レスポンス初期化'
  include_context 'ツイートを作成する', 1
  before(:each) { assign(:tweets, Tweet.all) }
  include_context 'View: ビューを描画'

  it '<div>タグがあること' do
    expect(@res).to have_selector('table tbody#tweet')
  end
end
