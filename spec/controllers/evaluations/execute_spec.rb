# coding: utf-8

require 'rails_helper'

describe EvaluationsController, type: :controller do
  zip_file_path = Rails.root.join('spec/fixtures/analysis.zip')
  model = Rack::Test::UploadedFile.new(File.open(zip_file_path))
  default_params = {model: model, from: '1000-01-01', to: '1000-01-31'}

  after(:all) { FileUtils.rm_rf(Dir[Rails.root.join('tmp/models/*')]) }

  shared_context 'リクエスト送信' do |params: default_params|
    before do
      allow(EvaluationJob).to receive(:perform_later).and_return(true)
      response = post(:execute, params: params)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正しいこと', status: 200, body: {}
  end

  describe '異常系' do
    required_keys = %i[model from to]

    CommonHelper.generate_combinations(required_keys).each do |absent_keys|
      context "#{absent_keys.join(',')}がない場合" do
        errors = absent_keys.map {|key| {'error_code' => "absent_param_#{key}"} }

        include_context 'リクエスト送信', params: default_params.except(*absent_keys)
        it_behaves_like 'レスポンスが正しいこと',
                        status: 400, body: {'errors' => errors}
      end
    end

    invalid_attribute = {
      from: ['invalid', nil],
      to: ['invalid', nil],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        errors = invalid_param.keys.map {|key| {'error_code' => "invalid_param_#{key}"} }
        params = default_params.merge(invalid_param)
        include_context 'リクエスト送信', params: params
        it_behaves_like 'レスポンスが正しいこと',
                        status: 400, body: {'errors' => errors}
      end
    end

    context '指定した期間が不正な場合' do
      errors = %w[from to].map {|param| {'error_code' => "invalid_param_#{param}"} }
      params = default_params.merge(from: '1000-01-31', to: '1000-01-01')
      include_context 'リクエスト送信', params: params
      it_behaves_like 'レスポンスが正しいこと',
                      status: 400, body: {'errors' => errors}
    end
  end
end
