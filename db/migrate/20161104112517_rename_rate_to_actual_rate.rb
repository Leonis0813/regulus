class RenameRateToActualRate < ActiveRecord::Migration
  def change
    rename_table :rates, :actual_rates
  end
end
