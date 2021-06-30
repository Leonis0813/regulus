class AddPerformedAtToAnalysesAndPredictions < ActiveRecord::Migration[5.0]
  def change
    add_column :analyses, :performed_at, :datetime, after: :state
    add_column :predictions, :performed_at, :datetime, after: :state
  end
end
