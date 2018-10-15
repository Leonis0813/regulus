class RemoveNumDataAndIntervalFromAnalyses < ActiveRecord::Migration
  def change
    remove_column :analyses, :num_data
    remove_column :analyses, :interval
  end
end
