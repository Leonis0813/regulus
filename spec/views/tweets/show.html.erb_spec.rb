# coding: utf-8
require 'rails_helper'

describe "tweets/show", :type => :view do
  before { render :template => 'tweets/show.html.erb' }

  it 'div タグが表示されていること' do
    expect(response).to match /div.*id="tweet"/
  end
end
