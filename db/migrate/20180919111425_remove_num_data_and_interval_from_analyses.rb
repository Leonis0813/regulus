class RemoveNumDataAndIntervalFromAnalyses < ActiveRecord::Migration[4.2]
  def up
    change_table :analyses, bulk: true do |t|
      t.remove :num_data
      t.remove :interval
    end
  end

  def down
    change_table :analyses, bulk: true do |t|
      t.integer :num_data
      t.integer :interval
    end
  end
end
