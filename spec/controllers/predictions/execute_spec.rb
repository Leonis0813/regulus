# coding: utf-8

require 'rails_helper'

describe PredictionsController, type: :controller do
  zip_file_path = Rails.root.join('spec', 'fixtures', 'analysis.zip')
  default_params = {model: Rack::Test::UploadedFile.new(File.open(zip_file_path))}

  after(:all) { FileUtils.rm_rf(Dir[Rails.root.join('tmp', 'models', '*')]) }

  shared_context 'リクエスト送信' do |params: default_params|
    before do
      allow(PredictionJob).to receive(:perform_later).and_return(true)
      response = post(:execute, params: params)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正しいこと', status: 200, body: {}
  end

  describe '異常系' do
    context 'modelがない場合' do
      errors = [{'error_code' => 'absent_param_model'}]
      include_context 'リクエスト送信', params: {}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'modelが不正な場合' do
      errors = [{'error_code' => 'invalid_param_model'}]
      include_context 'リクエスト送信', params: {model: 'invalid.txt'}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end
  end
end
