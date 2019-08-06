class AddMeansToPredictions < ActiveRecord::Migration[4.2]
  def change
    add_column :predictions,
               :means,
               :string,
               null: false, default: 'manual', after: :pair
  end
end
