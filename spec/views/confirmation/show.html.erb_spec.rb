require 'rails_helper'

describe 'confirmation/show', :type => :view do
  it 'should have 3 kinds of div tags' do
    render :template => 'confirmation/show.html.erb'
    expect(response).to match /div.*id="currency"/
    expect(response).to match /div.*id="tweet"/
    expect(response).to match /div.*id="article"/
  end
end
