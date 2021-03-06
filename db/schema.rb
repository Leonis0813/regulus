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

ActiveRecord::Schema.define(version: 20210306063112) do

  create_table "analyses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "analysis_id"
    t.datetime "from",                   default: '1970-01-01 00:00:00', null: false
    t.datetime "to",                     default: '2286-11-20 17:46:40', null: false
    t.string   "pair",                   default: "USDJPY",              null: false
    t.integer  "batch_size",             default: 0,                     null: false
    t.float    "min",         limit: 24
    t.float    "max",         limit: 24
    t.string   "state",                                                  null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.index ["analysis_id"], name: "index_analyses_on_analysis_id", unique: true, using: :btree
  end

  create_table "predictions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "prediction_id", default: "",       null: false
    t.string   "model",                            null: false
    t.datetime "from"
    t.datetime "to"
    t.string   "pair"
    t.string   "means",         default: "manual", null: false
    t.string   "result"
    t.string   "state",                            null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

end
