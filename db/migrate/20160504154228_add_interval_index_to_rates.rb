class AddIntervalIndexToRates < ActiveRecord::Migration
  def change
    add_index :rates, :interval
  end
end
