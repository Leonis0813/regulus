# coding: utf-8

require 'rails_helper'

describe Api::PredictionsController, type: :controller do
  shared_context 'リクエスト送信' do |query|
    before(:all) do
      response = client.get('/api/predictions', query)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  include_context 'トランザクション作成'

  before(:all) do
    now = Time.zone.now
    @predictions = Array.new(5) do |i|
      create(:prediction, means: 'auto', pair: 'EURJPY', created_at: now - i)
    end
    @predictions += Array.new(6) do |i|
      create(:prediction, means: 'manual', created_at: now - 10 - i)
    end
  end

  describe '正常系' do
    [
      [{means: 'auto'}, [0, 1, 2, 3, 4]],
      [{page: 2}, [10]],
      [{pair: 'EURJPY'}, [0, 1, 2, 3, 4]],
      [{per_page: 2}, [0, 1]],
      [{means: 'manual', page: 2, per_page: 2}, [7, 8]],
    ].each do |query, indexes|
      context "#{query}を指定した場合" do
        before(:all) do
          attributes = PredictionHelper.response_keys.sort
          predictions = indexes.map do |index|
            prediction = @predictions[index].slice(*attributes)
            prediction['created_at'] = prediction['created_at'].strftime('%FT%T.%LZ')
            prediction
          end
          @body = {predictions: predictions}.deep_stringify_keys
        end
        include_context 'リクエスト送信', query
        it_behaves_like 'レスポンスが正しいこと', status: 200
      end
    end
  end

  describe '異常系' do
    [
      {means: 'invalid'},
      {page: 'invalid'},
      {pair: 'invalid'},
      {per_page: 'invalid'},
      {means: 'invalid', pair: 'invalid', page: 'invalid', per_page: 'invalid'},
    ].each do |query|
      context "#{query}を指定した場合" do
        errors = query.keys.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context 'リクエスト送信', query
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
