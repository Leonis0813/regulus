class AddToDateIndexToRates < ActiveRecord::Migration
  def change
    add_index :rates, :to_date
  end
end
