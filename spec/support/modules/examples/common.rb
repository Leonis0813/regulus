# coding: utf-8

shared_examples 'ステータスコードが正しいこと' do
  it { expect(@res.status).to eq(200) }
end
