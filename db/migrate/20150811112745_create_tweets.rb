class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets, :id => false do |t|
      t.string :tweet_id, :null => false
      t.string :user_name, :null => false
      t.string :profile_image_url, :null => false
      t.text :full_text, :null => false
      t.datetime :tweeted_at, :null => false
      t.datetime :created_at, :null => false
    end
    execute 'ALTER TABLE tweets ADD PRIMARY KEY (tweet_id)'
  end
end
