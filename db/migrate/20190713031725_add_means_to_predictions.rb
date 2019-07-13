class AddMeansToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :means, :string, null: false, default: 'manual', after: :pair
  end
end
