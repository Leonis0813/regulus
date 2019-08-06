class ChangeStateOnAnalyses < ActiveRecord::Migration[4.2]
  def change
    change_column_null :analyses, :state, false, 'processing'
  end
end
