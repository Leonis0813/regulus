class AddAnalysisIdToPredictions < ActiveRecord::Migration[5.0]
  def change
    add_reference :predictions, :analysis, first: true
  end
end
