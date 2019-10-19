# coding: utf-8

shared_examples 'レスポンスが正しいこと' do |status: nil, body: nil|
  it_behaves_like 'ステータスコードが正しいこと', status

  it 'レスポンスボディが正しいこと' do
    expected_body = body || @body
    is_asserted_by { @response_body == expected_body }
  end
end

shared_examples 'ステータスコードが正しいこと' do |status|
  it do
    expected_status = status || @status
    is_asserted_by { @response_status == expected_status }
  end
end
