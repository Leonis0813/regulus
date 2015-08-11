class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :content
      t.date :date

      t.timestamps null: false
    end
  end
end
