# coding: utf-8
require 'rails_helper'

describe PredictionsController, type: :controller do
  zip_file_path = File.join(Rails.root, '/spec/fixtures/analysis.zip')
  default_params = {model: Rack::Test::UploadedFile.new(File.open(zip_file_path))}

  after(:all) do
    Prediction.destroy_all
    FileUtils.rm_rf(Dir[File.join(Rails.root, 'tmp/models/*')])
  end

  describe '正常系' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(PredictionJob).to receive(:perform_later).and_return(true)
        @res = client.post('/predictions', default_params)
        @pbody = JSON.parse(@res.body) rescue nil
      end
    end

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスが空であること' do
      is_asserted_by { @pbody == {} }
    end
  end

  describe '異常系' do
    context 'modelがない場合' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow(PredictionJob).to receive(:perform_later).and_return(true)
          @res = client.post('/predictions', {})
          @pbody = JSON.parse(@res.body) rescue nil
        end
      end

      it_behaves_like 'ステータスコードが正しいこと', '400'
      it_behaves_like 'エラーコードが正しいこと', ['absent_param_model']
    end

    context 'modelが不正な場合' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow(PredictionJob).to receive(:perform_later).and_return(true)
          @res = client.post('/predictions', {model: 'invalid.txt'})
          @pbody = JSON.parse(@res.body) rescue nil
        end
      end

      it_behaves_like 'ステータスコードが正しいこと', '400'
      it_behaves_like 'エラーコードが正しいこと', ['invalid_param_model']
    end
  end
end
