# coding: utf-8

require 'rails_helper'

describe '自動予測結果を検索する', type: :request do
  before(:all) do
    query = {means: 'auto'}
    response = http_client.get("#{base_url}/api/predictions", query, app_auth_header)
    @response_status = response.status
    @response_body = JSON.parse(response.body) rescue response.body
  end

  it 'レスポンスが正しいこと' do
    is_asserted_by { @response_status == 200 }
    is_asserted_by { @response_body.keys == %w[predictions] }

    @response_body['predictions'].each do |prediction|
      is_asserted_by { prediction.keys.sort == PredictionHelper.response_keys.sort }
    end
  end
end
