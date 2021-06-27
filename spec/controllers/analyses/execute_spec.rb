# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  default_params = {
    from: 2.months.ago.strftime('%F'),
    to: 1.month.ago.strftime('%F'),
    pair: 'USDJPY',
    batch_size: 100,
  }

  shared_context 'リクエスト送信' do |params: default_params|
    before do
      allow(AnalysisJob).to receive(:perform_later).and_return(true)
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
    required_keys = %i[from to pair batch_size]

    CommonHelper.generate_combinations(required_keys).each do |absent_keys|
      context "#{absent_keys.join(',')}がない場合" do
        errors = absent_keys.sort.map {|key| {'error_code' => "absent_param_#{key}"} }
        include_context 'リクエスト送信', params: default_params.except(*absent_keys)
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    invalid_attribute = {
      from: ['invalid', nil],
      to: ['invalid', nil],
      pair: ['invalid', nil],
      batch_size: ['invalid', nil],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        errors = invalid_param.keys.sort.map do |key|
          {'error_code' => "invalid_param_#{key}"}
        end
        include_context 'リクエスト送信', params: default_params.merge(invalid_param)
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
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
