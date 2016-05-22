# coding: utf-8

shared_context 'レスポンス初期化' do
  before(:all) { @res = nil }
end

shared_context 'View: ビューを描画' do
  before(:each) do
    render
    @res ||= response
  end
end

shared_context 'ユーザー名とパスワードをセットする' do
  before(:each) do
    encoded_key = Base64::encode64("dev:.dev")
    request.env['HTTP_AUTHORIZATION'] = "Basic #{encoded_key}"
  end
end
