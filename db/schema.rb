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
end
