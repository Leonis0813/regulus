class AddPairToAnalysesAndPredictions < ActiveRecord::Migration[4.2]
  def change
    add_column :analyses, :pair, :string, null: false, default: 'USDJPY', after: :to
    add_column :predictions, :pair, :string, after: :to
  end
end
