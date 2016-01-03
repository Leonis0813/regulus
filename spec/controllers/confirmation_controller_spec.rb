require 'rails_helper'

describe ConfirmationController, :type => :controller do
  describe 'GET #show' do
    it 'should respond success' do
      request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64("dev:.dev")
      get :show
      expect(response.status).to eq(200)
    end
  end
end
