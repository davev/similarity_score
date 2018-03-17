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

ActiveRecord::Schema.define(version: 20180317215719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "career_stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.float "war"
    t.integer "ab"
    t.integer "r"
    t.integer "h"
    t.float "ba"
    t.integer "hr"
    t.integer "rbi"
    t.float "obp"
    t.float "slg"
    t.float "ops"
    t.integer "ops_plus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_career_stats_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.integer "active_year_begin"
    t.integer "active_year_end"
    t.string "handle", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hof", default: false, null: false
    t.index ["handle"], name: "index_players_on_handle", unique: true
    t.index ["name"], name: "index_players_on_name"
  end

  create_table "similar_players", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "related_player_id", null: false
    t.integer "age"
    t.float "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "related_player_id"], name: "index_similar_players_on_player_id_and_related_player_id", unique: true
    t.index ["player_id"], name: "index_similar_players_on_player_id"
    t.index ["related_player_id"], name: "index_similar_players_on_related_player_id"
    t.index ["score"], name: "index_similar_players_on_score"
  end

  add_foreign_key "career_stats", "players"
  add_foreign_key "similar_players", "players"
  add_foreign_key "similar_players", "players", column: "related_player_id"
end
