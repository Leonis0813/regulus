class CreateEvaluationData < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluation_data do |t|
      t.references :evaluation
      t.date :from
      t.date :to
      t.string :prediction_result
      t.string :ground_truth
      t.timestamps null: false
    end

    add_index :evaluation_data, %i[evaluation_id from to], unique: true
  end
end
