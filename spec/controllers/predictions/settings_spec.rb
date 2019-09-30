# coding: utf-8

require 'rails_helper'

describe PredictionsController, type: :controller do
  prediction = Settings.prediction
  model_file = 'analysis.zip'
  zip_file_path = Rails.root.join('spec', 'fixtures', model_file)
  invalid_file_path = Rails.root.join('spec', 'fixtures', 'invalid.txt')
  default_params = {
    auto: {
      status: 'active',
      model: Rack::Test::UploadedFile.new(File.open(zip_file_path)),
    },
  }
  setting_file = Rails.root.join(prediction.auto.setting_file)
  model_dir = Rails.root.join(prediction.base_model_dir, prediction.auto.model_dir)

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      response = client.post('/predictions/settings', body)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end

    after(:all) do
      FileUtils.rm(setting_file) if File.exist?(setting_file)
      FileUtils.rm_rf(model_dir) if File.exist?(model_dir)
    end
  end

  shared_examples 'ファイルが作成されていること' do |expected|
    it '設定ファイルが作成されていること' do
      is_asserted_by { File.exist?(setting_file) }

      setting = YAML.load_file(setting_file)
      expected.each do |key, value|
        is_asserted_by { setting[key] == value }
      end
    end

    it 'モデルが出力されていること', if: expected['status'] == 'active' do
      is_asserted_by { File.exist?(Rails.root.join(model_dir, model_file)) }
    end
  end

  describe '正常系' do
    context '定期予測を有効にする場合' do
      include_context 'リクエスト送信'
      it_behaves_like 'レスポンスが正しいこと', status: 200, body: {}
      it_behaves_like 'ファイルが作成されていること',
                      'status' => 'active', 'filename' => model_file
    end

    context '定期予測を無効にする場合' do
      include_context 'リクエスト送信', body: {auto: {status: 'inactive'}}
      it_behaves_like 'レスポンスが正しいこと', status: 200, body: {}
      it_behaves_like 'ファイルが作成されていること', 'status' => 'inactive'
    end
  end

  describe '異常系' do
    [
      ['auto', {}],
      ['auto[status]', {auto: {}}],
    ].each do |absent_key, body|
      context "#{absent_key}がない場合" do
        errors = [{'error_code' => 'absent_param_auto'}]
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    [
      ['auto[status]', {auto: {status: 'invalid'}}],
      ['auto[model]', {auto: {status: 'active'}}],
      ['auto[model]', {auto: {status: 'active', model: 'invalid.txt'}}],
      [
        'auto[model]',
        {
          auto: {
            status: 'active',
            model: Rack::Test::UploadedFile.new(File.open(invalid_file_path)),
          },
        },
      ],
    ].each do |invalid_key, body|
      context "#{invalid_key}が不正な場合" do
        errors = [{'error_code' => 'invalid_param_auto'}]
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
