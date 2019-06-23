class ChangeStateOnAnalyses < ActiveRecord::Migration
  def change
    change_column_null :analyses, :state, false, 'processing'
  end
end
