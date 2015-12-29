class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies, :id => false do |t|
      t.datetime :from_date
      t.datetime :to_date
      t.string :pair
      t.string :interval
      t.float :open, :null => false
      t.float :close, :null => false
      t.float :high, :null => false
      t.float :low, :null => false
      t.timestamps
    end
    execute 'ALTER TABLE currencies ADD PRIMARY KEY (from_date, to_date, pair, `interval`)'
  end
end
