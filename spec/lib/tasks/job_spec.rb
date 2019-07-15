# coding: utf-8

require 'rake_helper'
require 'rails_helper'

describe 'job:prediction' do
  prediction = Settings.prediction
  filename = 'analysis.zip'

  before(:all) { @task = Rake.application['job:prediction'] }

  shared_context '設定ファイルを作成' do |param|
    before(:all) do
      File.open(Rails.root.join(prediction.auto.setting_file), 'w') do |file|
        YAML.dump(param, file)
      end
    end

    after(:all) { FileUtils.rm(Rails.root.join(prediction.auto.setting_file)) }
  end

  shared_context 'タスクを実行' do
    before(:all) do
      @before_count = Prediction.count
      @task.invoke
    end
  end

  context '定期予測が無効な場合' do
    include_context '設定ファイルを作成', 'status' => 'inactive'
    include_context 'タスクを実行'

    it '予測ジョブが作成されていないこと' do
      is_asserted_by { Prediction.count == @before_count }
    end
  end

  context '定期予測が有効な場合' do
    model_dir = Rails.root.join(prediction.base_model_dir, prediction.auto.model_dir)

    before(:all) do
      FileUtils.mkdir_p(model_dir)
      FileUtils.cp(Rails.root.join('spec', 'fixtures', filename), model_dir)
    end
    after(:all) { FileUtils.rm_rf(model_dir) }
    include_context 'トランザクション作成'
    include_context '設定ファイルを作成', 'status' => 'active', 'filename' => filename
    include_context 'タスクを実行'

    it '予測ジョブが作成されていること' do
      is_asserted_by { Prediction.count == @before_count + 1 }
    end
  end
end
