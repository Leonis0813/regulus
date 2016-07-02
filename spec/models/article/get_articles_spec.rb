# coding: utf-8
require 'rails_helper'

describe Article, :type => :model do
  shared_context '記事を取得する' do
    before(:all) { @res = Article.get_articles }
  end

  shared_examples '記事が取得されていること' do |expected_size|
    it { expect(@res.size).to eq(expected_size) }
  end

  context '記事が十分にある場合' do
    include_context '記事を作成する', 100
    include_context '記事を取得する'
    it_behaves_like '記事が取得されていること', 20
  end

  context '記事が不十分な場合' do
    include_context '記事を作成する', 5
    include_context '記事を取得する'
    it_behaves_like '記事が取得されていること', 5
  end
end
