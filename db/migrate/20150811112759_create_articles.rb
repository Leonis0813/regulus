class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :content
      t.date :date

      t.timestamps null: false
    end
  end
end
