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

ActiveRecord::Schema.define(version: 2019_12_20_165049) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text "message"
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_comments_on_game_id"
    t.index ["user_id", "game_id"], name: "index_comments_on_user_id_and_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.bigint "first_move_id"
    t.bigint "creating_user_id"
    t.bigint "invited_user_id"
    t.bigint "winner_id"
    t.index ["creating_user_id"], name: "index_games_on_creating_user_id"
    t.index ["first_move_id"], name: "index_games_on_first_move_id"
    t.index ["invited_user_id"], name: "index_games_on_invited_user_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "start_piece", limit: 2
    t.integer "end_piece", limit: 2
    t.integer "start_x", limit: 2
    t.integer "start_y", limit: 2
    t.integer "end_x", limit: 2
    t.integer "end_y", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_x", "end_y"], name: "index_moves_on_end_x_and_end_y"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["start_piece"], name: "index_moves_on_start_piece"
    t.index ["start_x", "start_y"], name: "index_moves_on_start_x_and_start_y"
    t.index ["user_id"], name: "index_moves_on_user_id"
  end

  create_table "pieces", force: :cascade do |t|
    t.integer "x_position", limit: 2
    t.integer "y_position", limit: 2
    t.integer "piece", limit: 2
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_pieces_on_game_id"
  end

  create_table "positions", force: :cascade do |t|
    t.integer "x_position", limit: 2
    t.integer "y_position", limit: 2
    t.integer "piece", limit: 2
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_positions_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "games", "users", column: "creating_user_id"
  add_foreign_key "games", "users", column: "first_move_id"
  add_foreign_key "games", "users", column: "invited_user_id"
  add_foreign_key "games", "users", column: "winner_id"
end
