# coding: utf-8
require 'rails_helper'

describe "rates/show", :type => :view do
  before(:all) { @response = nil }

  before(:each) do
    render
    @response ||= response
  end

  it 'div タグが表示されていること' do
    expect(@response).to have_selector('div#rate')
  end

  it '<form>タグがあること' do
    expect(@response).to have_selector('form[action="/rates"][method="get"]')
  end

  %w[ pair interval ].each do |id|
    it "id=#{id}の<select>タグがあること" do
      expect(@response).to have_selector("select##{id}")
    end
  end

  (Settings.pairs + Settings.intervals).each do |text|
    it "#{text}が選択できること" do
      expect(@response).to have_selector('option', :text => text)
    end
  end

  %w[ USDJPY 5-min ].each do |text|
    it "#{text}が選択されていること" do
      expect(@response).to have_selector('option[selected]', :text => text)
    end
  end
end
