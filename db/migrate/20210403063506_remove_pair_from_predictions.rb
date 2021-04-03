class RemovePairFromPredictions < ActiveRecord::Migration[5.0]
  def up
    remove_column :predictions, :pair
  end

  def down
    add_column :predictions, :pair, :string, after: :to
  end
end
