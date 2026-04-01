# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_31_000010) do
  create_table "price_snapshots", force: :cascade do |t|
    t.decimal "close", precision: 12, scale: 4
    t.datetime "created_at", null: false
    t.decimal "high", precision: 12, scale: 4
    t.decimal "low", precision: 12, scale: 4
    t.decimal "open", precision: 12, scale: 4
    t.decimal "price", precision: 12, scale: 4
    t.datetime "recorded_at", null: false
    t.integer "stock_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "volume", precision: 12, scale: 4
    t.index ["stock_id", "recorded_at"], name: "index_price_snapshots_on_stock_id_and_recorded_at", unique: true
    t.index ["stock_id"], name: "index_price_snapshots_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "company_name", null: false
    t.datetime "created_at", null: false
    t.decimal "last_price", precision: 12, scale: 4
    t.datetime "last_synced_at"
    t.string "ticker", null: false
    t.datetime "updated_at", null: false
    t.index ["ticker"], name: "index_stocks_on_ticker", unique: true
  end

  add_foreign_key "price_snapshots", "stocks"
ActiveRecord::Schema[8.1].define(version: 2026_03_31_181045) do
  create_table "league_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "league_id", null: false
    t.integer "role"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["league_id"], name: "index_league_memberships_on_league_id"
    t.index ["user_id"], name: "index_league_memberships_on_user_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "owner_id"
    t.datetime "updated_at", null: false
  end

  create_table "portfolios", force: :cascade do |t|
    t.decimal "cash_balance"
    t.datetime "created_at", null: false
    t.integer "league_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["league_id"], name: "index_portfolios_on_league_id"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "league_memberships", "leagues"
  add_foreign_key "league_memberships", "users"
  add_foreign_key "portfolios", "leagues"
  add_foreign_key "portfolios", "users"
end
