class AddFromAndToAndBatchSizeToAnalyses < ActiveRecord::Migration
  def change
    change_table :analyses, bulk: true do |t|
      t.datetime :from, after: :id, null: false, default: Time.at.utc(0)
      t.datetime :to, after: :from, null: false, default: Time.at.utc(10**10)
      t.integer :batch_size, after: :to, null: false, default: 0
    end
  end
end
