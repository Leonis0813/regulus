class CreateEvaluationTestData < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluation_test_data do |t|
      t.references :evaluation
      t.date :from
      t.date :to
      t.float :up_probability
      t.float :down_probability
      t.string :ground_truth
      t.timestamps null: false
    end

    add_index :evaluation_test_data, %i[evaluation_id from to], unique: true
  end
end
