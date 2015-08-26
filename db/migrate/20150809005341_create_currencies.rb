class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies, :id => false do |t|
      t.datetime :time
      t.string :pair
      t.float :rate, :null => false
    end
    execute 'ALTER TABLE currencies ADD PRIMARY KEY (time, pair)'
  end
end
