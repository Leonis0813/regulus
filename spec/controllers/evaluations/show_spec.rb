# coding: utf-8

require 'rails_helper'

describe EvaluationsController, type: :controller do
  shared_context 'リクエスト送信' do
    before do
      get(:show, params: {evaluation_id: @evaluation_id})
      @response_status = response.status
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    before { @evaluation_id = create(:evaluation).evaluation_id }
    include_context 'リクエスト送信'

    it 'ステータスコードが正しいこと' do
      is_asserted_by { @response_status == 200 }
    end
  end

  describe '異常系' do
    before(:all) { @evaluation_id = 'not_exist' }
    include_context 'リクエスト送信'

    it 'ステータスコードが正しいこと' do
      is_asserted_by { @response_status == 404 }
    end
  end
end
