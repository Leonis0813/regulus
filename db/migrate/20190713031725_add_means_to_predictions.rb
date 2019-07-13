class AddMeansToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :means, :string, null: false, after: :pair
  end
end
