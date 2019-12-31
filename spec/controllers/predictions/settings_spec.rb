# coding: utf-8

require 'rails_helper'

describe PredictionsController, type: :controller do
  prediction = Settings.prediction
  model_file = 'analysis.zip'
  zip_file_path = Rails.root.join('spec', 'fixtures', model_file)
  invalid_file_path = Rails.root.join('spec', 'fixtures', 'invalid.txt')
  active_params = {
    status: 'active',
    model: Rack::Test::UploadedFile.new(File.open(zip_file_path)),
  }
  inactive_params = {
    status: 'inactive',
    pair: 'USDJPY',
  }
  default_params = {auto: active_params}
  active_config = {'pair' => 'USDJPY', 'status' => 'active', 'filename' => 'test.zip'}
  inactive_config = {'pair' => 'USDJPY', 'status' => 'inactive'}
  default_configs = [inactive_config]
  config_file = Rails.root.join(prediction.auto.config_file)
  model_dir = Rails.root.join(prediction.base_model_dir, prediction.auto.model_dir)

  shared_context '設定ファイルを作成' do |configs: default_configs|
    before(:all) do
      File.open(config_file, 'w') {|file| YAML.dump(configs, file) }
    end

    after(:all) { FileUtils.rm(config_file) }
  end

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      response = client.put('/predictions/settings', body)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end

    after(:all) { FileUtils.rm_rf(model_dir) if File.exist?(model_dir) }
  end

  shared_examples 'ファイルが作成されていること' do |expected|
    it '設定ファイルが作成されていること' do
      is_asserted_by do
        YAML.load_file(config_file).any? {|config| config == expected }
      end
    end

    it 'モデルが出力されていること', if: expected['status'] == 'active' do
      file_path = Rails.root.join(model_dir, expected['pair'], model_file)
      is_asserted_by { File.exist?(file_path) }
    end
  end

  describe '正常系' do
    context '定期予測を有効にする場合' do
      include_context '設定ファイルを作成'
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 200
      it_behaves_like 'ファイルが作成されていること',
                      'status' => 'active', 'filename' => model_file, 'pair' => 'USDJPY'
    end

    context '定期予測を無効にする場合' do
      body = default_params.merge(auto: inactive_params)
      include_context '設定ファイルを作成', configs: [active_config]
      include_context 'リクエスト送信', body: body
      it_behaves_like 'ステータスコードが正しいこと', 200
      it_behaves_like 'ファイルが作成されていること',
                      'status' => 'inactive', 'pair' => 'USDJPY'
    end

    context '設定ファイルが空ファイルの場合' do
      before(:all) { FileUtils.touch(config_file) }
      after(:all) { FileUtils.rm(config_file) }
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 200
      it_behaves_like 'ファイルが作成されていること',
                      'status' => 'active', 'filename' => model_file, 'pair' => 'USDJPY'
    end
  end

  describe '異常系' do
    [
      ['auto', {}],
      ['status', {auto: {pair: 'USDJPY'}}],
      ['model', {auto: {status: 'active'}}],
      ['pair', {auto: {status: 'inactive'}}],
    ].each do |absent_key, body|
      context "#{absent_key}がない場合" do
        errors = [{'error_code' => "absent_param_#{absent_key}"}]
        include_context '設定ファイルを作成'
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    [
      ['status', {auto: {status: 'invalid'}}],
      ['model', {auto: {status: 'active', model: 'invalid.txt'}}],
      [
        'model',
        {
          auto: {
            status: 'active',
            model: Rack::Test::UploadedFile.new(File.open(invalid_file_path)),
          },
        },
      ],
    ].each do |invalid_key, body|
      context "#{invalid_key}が不正な場合" do
        errors = [{'error_code' => "invalid_param_#{invalid_key}"}]
        include_context '設定ファイルを作成'
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
