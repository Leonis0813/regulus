class AddFromAndToAndBatchSizeToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :from, :datetime, after: :id, null: false, default: Time.at.utc(0)
    add_column :analyses, :to, :datetime, after: :from, null: false, default: Time.at.utc(10**10)
    add_column :analyses, :batch_size, :integer, after: :to, null: false, default: 0
  end
end
