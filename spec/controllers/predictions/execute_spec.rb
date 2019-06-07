# coding: utf-8

require 'rails_helper'

describe PredictionsController, type: :controller do
  zip_file_path = Rails.root.join('spec', 'fixtures', 'analysis.zip')
  default_params = {model: Rack::Test::UploadedFile.new(File.open(zip_file_path))}

  after(:all) { FileUtils.rm_rf(Dir[Rails.root.join('tmp', 'models', '*')]) }

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(PredictionJob).to receive(:perform_later).and_return(true)
        response = client.post('/predictions', body)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue nil
      end
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
  end

  describe '異常系' do
    context 'modelがない場合' do
      body = [{'error_code' => 'absent_param_model'}]
      include_context 'リクエスト送信', body: {}
      it_behaves_like 'レスポンスが正常であること', status: 400, body: body
    end

    context 'modelが不正な場合' do
      body = [{'error_code' => 'invalid_param_model'}]
      include_context 'リクエスト送信', body: {model: 'invalid.txt'}
      it_behaves_like 'レスポンスが正常であること', status: 400, body: body
    end
  end
end
