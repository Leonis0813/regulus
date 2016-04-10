# coding: utf-8
require 'rails_helper'

describe Tweet, :type => :model do
  shared_context 'ツイートを取得する' do
    before(:all) { @res = Tweet.get_tweets }
  end

  shared_examples 'ツイートが取得されていること' do |expected_size|
    it { expect(@res.size).to eq(expected_size) }
  end

  context 'ツイートが十分にある場合' do
    include_context 'ツイートを作成する', 150
    include_context 'ツイートを取得する'
    it_behaves_like 'ツイートが取得されていること', 100
  end

  context 'ツイートが不十分な場合' do
    include_context 'ツイートを作成する', 20
    include_context 'ツイートを取得する'
    it_behaves_like 'ツイートが取得されていること', 20
  end
end
