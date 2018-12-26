class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.string :model
      t.datetime :from
      t.datetime :to
      t.string :result
      t.string :state
      t.timestamps null: false
    end
  end
end
