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

ActiveRecord::Schema.define(version: 20210614135915) do

  create_table "analyses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "analysis_id"
    t.datetime "from",                    default: '1970-01-01 00:00:00', null: false
    t.datetime "to",                      default: '2286-11-20 17:46:40', null: false
    t.string   "pair",                    default: "USDJPY",              null: false
    t.integer  "batch_size",              default: 0,                     null: false
    t.float    "min",          limit: 24
    t.float    "max",          limit: 24
    t.string   "state",                                                   null: false
    t.datetime "performed_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.index ["analysis_id"], name: "index_analyses_on_analysis_id", unique: true, using: :btree
  end

  create_table "evaluation_data", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "evaluation_id"
    t.date     "from"
    t.date     "to"
    t.string   "prediction_result"
    t.string   "ground_truth"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["evaluation_id", "from", "to"], name: "index_evaluation_data_on_evaluation_id_and_from_and_to", unique: true, using: :btree
    t.index ["evaluation_id"], name: "index_evaluation_data_on_evaluation_id", using: :btree
  end

  create_table "evaluations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "analysis_id"
    t.string   "evaluation_id"
    t.string   "model"
    t.date     "from"
    t.date     "to"
    t.float    "log_less",      limit: 24
    t.string   "state"
    t.datetime "performed_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["analysis_id"], name: "index_evaluations_on_analysis_id", using: :btree
    t.index ["evaluation_id"], name: "index_evaluations_on_evaluation_id", unique: true, using: :btree
  end

  create_table "predictions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "analysis_id"
    t.string   "prediction_id", default: "",       null: false
    t.string   "model",                            null: false
    t.datetime "from"
    t.datetime "to"
    t.string   "means",         default: "manual", null: false
    t.string   "result"
    t.string   "state",                            null: false
    t.datetime "performed_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["analysis_id"], name: "index_predictions_on_analysis_id", using: :btree
  end

end
