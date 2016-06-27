class AddPairIndexToRates < ActiveRecord::Migration
  def change
    add_index :rates, :pair
  end
end
