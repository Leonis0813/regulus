# coding: utf-8

shared_examples 'レスポンスが正しいこと' do |status: nil, body: nil|
  it 'ステータスコードが正しいこと' do
    expected_status = status || @status
    is_asserted_by { @response_status == expected_status }
  end

  it 'レスポンスボディが正しいこと' do
    expected_body = body || @body
    is_asserted_by { @response_body == expected_body }
  end
end
