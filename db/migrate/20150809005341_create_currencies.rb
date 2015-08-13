class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies, :id => false do |t|
      t.datetime :time
      t.string :pair
      t.float :bid, :null => false
      t.float :ask, :null => false
      t.float :open, :null => false
      t.float :high, :null => false
      t.float :low, :null => false
    end
    execute 'ALTER TABLE currencies ADD PRIMARY KEY (time, pair)'
  end
end
