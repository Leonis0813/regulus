# coding: utf-8

require 'rails_helper'

describe 'predictions/manage', type: :view do
  include PredictionViewHelper

  before(:all) do
    Kaminari.config.default_per_page = PredictionViewHelper::DEFAULT_PER_PAGE
    @prediction = Prediction.new
    @configs = []
  end

  before do
    render template: 'predictions/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '自動予測設定が有効になっている場合' do
    config = {'pair' => 'USDJPY', 'status' => 'active', 'filename' => 'test.zip'}
    before(:all) { @configs = [config] }
    after(:all) { @configs = [] }
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト', expected: {configs: [config]}
  end

  context '実行中の場合' do
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する'
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '予測ジョブの状態が正しいこと', state: 'processing'
  end

  context '完了している場合' do
    context '予測結果が上昇の場合' do
      param = {state: 'completed', result: 'up'}
      include_context 'トランザクション作成'
      include_context '予測ジョブを登録する', update_attribute: param
      include_context 'HTML初期化'
      it_behaves_like '予測画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like '予測ジョブの状態が正しいこと', param
    end

    context '予測結果が下降の場合' do
      param = {state: 'completed', result: 'down'}
      include_context 'トランザクション作成'
      include_context '予測ジョブを登録する', update_attribute: param
      include_context 'HTML初期化'
      it_behaves_like '予測画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like '予測ジョブの状態が正しいこと', param
    end

    context '予測結果がレンジの場合' do
      param = {state: 'completed', result: 'range'}
      include_context 'トランザクション作成'
      include_context '予測ジョブを登録する', update_attribute: param
      include_context 'HTML初期化'
      it_behaves_like '予測画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like '予測ジョブの状態が正しいこと', param
    end
  end

  context 'エラーの場合' do
    param = {state: 'error'}
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する', update_attribute: param
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '予測ジョブの状態が正しいこと', param
  end

  context '自動実行の場合' do
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する', update_attribute: {means: 'auto'}
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '予測ジョブの状態が正しいこと', state: 'processing'
  end

  total = PredictionViewHelper::DEFAULT_PER_PAGE * (Kaminari.config.window + 2)
  context "予測ジョブ情報が#{total}件の場合" do
    include_context 'トランザクション作成'
    include_context '予測ジョブを登録する', total: total
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'prediction'
  end
end
