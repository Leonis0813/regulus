class CreateAnalyses < ActiveRecord::Migration[4.2]
  def change
    create_table :analyses do |t|
      t.integer :num_data
      t.integer :interval
      t.string :state
      t.timestamps null: false
    end
  end
end
