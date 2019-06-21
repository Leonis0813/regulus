class AddPairToAnalysesAndPredictions < ActiveRecord::Migration
  def change
    add_column :analyses, :pair, :string, null: false, after: :to
    add_column :predictions, :pair, :string, after: :to
  end
end
