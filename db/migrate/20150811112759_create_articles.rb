class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles, :id => false do |t|
      t.datetime :published, :null => false
      t.string :title, :null => false
      t.text :summary, :null => false
      t.string :url
      t.datetime :created_at, :null => false
    end
    execute 'ALTER TABLE articles ADD PRIMARY KEY (published, title)'
  end
end
