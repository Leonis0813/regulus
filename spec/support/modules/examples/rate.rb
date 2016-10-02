# coding: utf-8

shared_examples 'インスタンス変数(rates)が正しいこと' do |num_rate|
  it { expect(@rates.size).to eq(num_rate) }
end

shared_examples 'インスタンス変数(averages)が正しいこと' do |num_averages|
  it { expect(@averages.size).to eq(num_averages) }
end
