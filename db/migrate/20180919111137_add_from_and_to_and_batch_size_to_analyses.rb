class AddFromAndToAndBatchSizeToAnalyses < ActiveRecord::Migration[4.2]
  def change
    change_table :analyses, bulk: true do |t|
      t.datetime :from, after: :id, null: false, default: Time.at(0).utc
      t.datetime :to, after: :from, null: false, default: Time.at(10**10).utc
      t.integer :batch_size, after: :to, null: false, default: 0
    end
  end
end
