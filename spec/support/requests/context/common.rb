# coding: utf-8
shared_context '共通設定' do
  before(:all) do
    @base_url = 'http://160.16.66.112:888'
    @content_type_json = {'Content-Type' => 'application/json'}
    @hc = HTTPClient.new
  end
end
