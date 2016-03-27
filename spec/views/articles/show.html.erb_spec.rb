# coding: utf-8
require 'rails_helper'

describe "articles/show", :type => :view do
  before { render :template => 'article/show.html.erb' }

  it 'div タグが表示されていること' do
    expect(response).to match /div.*id="article"/
  end
end
