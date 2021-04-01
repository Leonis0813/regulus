class AddMinAndMaxToAnalyses < ActiveRecord::Migration[5.0]
  def change
    change_table :analyses, bulk: true do |t|
      t.float :min, after: :batch_size
      t.float :max, after: :min
    end
  end
end
