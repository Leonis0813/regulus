class AddPredictionIdToPredictions < ActiveRecord::Migration[5.0]
  def change
    add_column :predictions,
               :prediction_id,
               :string,
               null: false, default: '', after: :id
  end
end
