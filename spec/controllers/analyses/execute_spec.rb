# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  default_params = {
    from: 2.months.ago.strftime('%F'),
    to: 1.month.ago.strftime('%F'),
    pair: 'USDJPY',
    batch_size: 100,
  }

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(AnalysisJob).to receive(:perform_later).and_return(true)
        response = client.post('/analyses', body)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue nil
      end
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正しいこと', status: 200, body: {}
  end

  describe '異常系' do
    test_cases = [].tap do |tests|
      (default_params.keys.size - 1).times do |i|
        tests << default_params.keys.combination(i + 1).to_a
      end
    end.flatten(1)

    test_cases.each do |error_keys|
      context "#{error_keys.join(',')}がない場合" do
        selected_keys = default_params.keys - error_keys
        errors = error_keys.sort.map {|key| {'error_code' => "absent_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.slice(*selected_keys)
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end

      context "#{error_keys.join(',')}が不正な場合" do
        invalid_params = error_keys.map {|key| [key, 'invalid'] }.to_h
        errors = error_keys.sort.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.merge(invalid_params)
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
