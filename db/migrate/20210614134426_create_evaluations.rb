class CreateEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluations do |t|
      t.references :analysis
      t.string :evaluation_id
      t.string :model
      t.date :from
      t.date :to
      t.float :log_less
      t.string :state
      t.datetime :performed_at
      t.timestamps null: false
    end

    add_index :evaluations, :evaluation_id, unique: true
  end
end
