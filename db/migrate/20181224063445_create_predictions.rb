class CreatePredictions < ActiveRecord::Migration[4.2]
  def change
    create_table :predictions do |t|
      t.string :model, null: false
      t.datetime :from
      t.datetime :to
      t.string :result
      t.string :state, null: false
      t.timestamps null: false
    end
  end
end
