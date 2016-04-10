# coding: utf-8
require 'rails_helper'

describe "rates/show", :type => :view do
  before { render :template => 'rates/show.html.erb' }

  it 'div タグが表示されていること' do
    expect(response).to match /div.*id="rate"/
  end
end
