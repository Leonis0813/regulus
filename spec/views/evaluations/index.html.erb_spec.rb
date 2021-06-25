# coding: utf-8

require 'rails_helper'

describe 'evaluations/index', type: :view do
  include EvaluationViewHelper

  before(:all) do
    Kaminari.config.default_per_page = EvaluationViewHelper::DEFAULT_PER_PAGE
    @evaluation = Evaluation.new
  end

  before(:each) do
    render template: 'evaluations/index', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '評価ジョブの状態が正しいこと', state: 'waiting'
  end

  context '実行中の場合' do
    param = {state: 'processing'}
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', update_attribute: param
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '評価ジョブの状態が正しいこと', param
  end

  context '完了している場合' do
    param = {state: 'completed'}
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', update_attribute: param
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '評価ジョブの状態が正しいこと', param
  end

  context 'エラーの場合' do
    param = {state: 'error'}
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', update_attribute: param
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '評価ジョブの状態が正しいこと', param
  end

  total = EvaluationViewHelper::DEFAULT_PER_PAGE * (Kaminari.config.window + 2)
  context "評価ジョブ情報が#{total}件の場合" do
    include_context 'トランザクション作成'
    include_context '評価ジョブを登録する', total: total
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'evaluation'
  end
end
