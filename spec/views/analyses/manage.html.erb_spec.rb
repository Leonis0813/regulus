# coding: utf-8

require 'rails_helper'

describe 'analyses/manage', type: :view do
  include AnalysisViewHelper

  before(:all) do
    Kaminari.config.default_per_page = AnalysisViewHelper::DEFAULT_PER_PAGE
    @analysis = Analysis.new
  end

  before(:each) do
    render template: 'analyses/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行中の場合' do
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '分析画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '分析ジョブの状態が正しいこと', '実行中'
  end

  context '完了しているの場合' do
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する', update_attribute: {state: 'completed'}
    include_context 'HTML初期化'
    it_behaves_like '分析画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '分析ジョブの状態が正しいこと', '完了'
  end

  context 'エラーの場合' do
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する', update_attribute: {state: 'error'}
    include_context 'HTML初期化'
    it_behaves_like '分析画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '分析ジョブの状態が正しいこと', 'エラー'
  end

  total = AnalysisViewHelper::DEFAULT_PER_PAGE * (Kaminari.config.window + 2)
  context "分析ジョブ情報が#{total}件の場合" do
    include_context 'トランザクション作成'
    include_context '分析ジョブを登録する', total: total
    include_context 'HTML初期化'
    it_behaves_like '分析画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'analysis'
  end
end
