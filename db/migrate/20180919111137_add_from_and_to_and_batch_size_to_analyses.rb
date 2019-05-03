class AddFromAndToAndBatchSizeToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :from, :datetime, after: :id, null: false
    add_column :analyses, :to, :datetime, after: :from, null: false
    add_column :analyses, :batch_size, :integer, after: :to, null: false
  end
end
