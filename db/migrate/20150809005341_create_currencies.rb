class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name
      t.integer :price
      t.date :date

      t.timestamps null: false
    end
  end
end
