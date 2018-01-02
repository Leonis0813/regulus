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

ActiveRecord::Schema.define(version: 20180102083542) do

  create_table "analyses", force: :cascade do |t|
    t.integer  "num_data",   limit: 4
    t.integer  "interval",   limit: 4
    t.string   "state",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "candle_sticks", force: :cascade do |t|
    t.datetime "from",                null: false
    t.datetime "to",                  null: false
    t.string   "pair",     limit: 6,  null: false
    t.string   "interval", limit: 8,  null: false
    t.float    "open",     limit: 24, null: false
    t.float    "close",    limit: 24, null: false
    t.float    "high",     limit: 24, null: false
    t.float    "low",      limit: 24, null: false
  end

  add_index "candle_sticks", ["from", "to", "pair"], name: "from", unique: true, using: :btree

  create_table "rates", force: :cascade do |t|
    t.datetime "time",            null: false
    t.string   "pair", limit: 6,  null: false
    t.float    "bid",  limit: 24, null: false
    t.float    "ask",  limit: 24, null: false
  end

  add_index "rates", ["pair"], name: "index_pair", using: :btree
  add_index "rates", ["time"], name: "index_time", using: :btree

end
