class RemoveNumDataAndIntervalFromAnalyses < ActiveRecord::Migration
  def change
    change_table :analyses, bulk: true do |t|
      t.remove :num_data
      t.remove :interval
    end
  end
end
