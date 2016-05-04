# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160504154515) do

  create_table "articles", id: false, force: :cascade do |t|
    t.datetime "published",                null: false
    t.string   "title",      limit: 255,   null: false
    t.text     "summary",    limit: 65535, null: false
    t.string   "url",        limit: 255
    t.datetime "created_at",               null: false
  end

  add_index "articles", ["created_at"], name: "index_articles_on_created_at", using: :btree

  create_table "rates", id: false, force: :cascade do |t|
    t.datetime "from_date",                           null: false
    t.datetime "to_date",                             null: false
    t.string   "pair",       limit: 255, default: "", null: false
    t.string   "interval",   limit: 255, default: "", null: false
    t.float    "open",       limit: 24,               null: false
    t.float    "close",      limit: 24,               null: false
    t.float    "high",       limit: 24,               null: false
    t.float    "low",        limit: 24,               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["interval"], name: "index_rates_on_interval", using: :btree
  add_index "rates", ["pair"], name: "index_rates_on_pair", using: :btree
  add_index "rates", ["to_date"], name: "index_rates_on_to_date", using: :btree

  create_table "tweets", primary_key: "tweet_id", force: :cascade do |t|
    t.string   "user_name",         limit: 255,   null: false
    t.string   "profile_image_url", limit: 255,   null: false
    t.text     "full_text",         limit: 65535, null: false
    t.datetime "tweeted_at",                      null: false
    t.datetime "created_at",                      null: false
  end

  add_index "tweets", ["created_at"], name: "index_tweets_on_created_at", using: :btree

end
