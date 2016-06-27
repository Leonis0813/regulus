# coding: utf-8
require 'rails_helper'

describe "articles/show", :type => :view do
  include_context 'レスポンス初期化'
  include_context 'View: ビューを描画'

  it '<div>タグがあること' do
    expect(@res).to have_selector('div#article')
  end
end
