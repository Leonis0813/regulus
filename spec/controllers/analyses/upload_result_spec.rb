# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  analysis = Settings.analysis
  model_file = 'analysis.zip'
  zip_file_path = Rails.root.join('spec', 'fixtures', model_file)
  invalid_file_path = Rails.root.join('spec', 'fixtures', 'invalid.txt')
  default_params = {
    model: Rack::Test::UploadedFile.new(File.open(zip_file_path)),
  }

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      response = client.put('/analyses/result', body)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  describe '正常系' do
    dir = Rails.root.join(analysis.base_model_dir, analysis.tensorboard_dir)
    include_context 'トランザクション作成'
    before(:all) { FileUtils.mkdir_p(dir) }
    after(:all) { FileUtils.rm_rf(dir) }
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正しいこと', status: 200, body: {}
  end

  describe '異常系' do
    context 'modelがない場合' do
      errors = [{'error_code' => 'absent_param_model'}]
      include_context 'リクエスト送信', body: {}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'modelの型が不正な場合' do
      errors = [{'error_code' => 'invalid_param_model'}]
      include_context 'リクエスト送信', body: {model: 'invalid'}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'modelのファイルが不正な場合' do
      body = {model: Rack::Test::UploadedFile.new(File.open(invalid_file_path))}
      errors = [{'error_code' => 'invalid_param_model'}]
      include_context 'リクエスト送信', body: body
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end
  end
end
