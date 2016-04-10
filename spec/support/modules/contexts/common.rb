# coding: utf-8
shared_context 'ユーザー名とパスワードをセットする' do
  before do
    encoded_key = Base64::encode64("dev:.dev")
    request.env['HTTP_AUTHORIZATION'] = "Basic #{encoded_key}"
  end
end
