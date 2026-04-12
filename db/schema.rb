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

ActiveRecord::Schema[8.1].define(version: 2026_04_12_080842) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "friendships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "friend_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "holdings", force: :cascade do |t|
    t.decimal "average_cost", precision: 15, scale: 4, null: false
    t.datetime "created_at", null: false
    t.string "direction", default: "long", null: false
    t.integer "portfolio_id", null: false
    t.decimal "quantity", precision: 15, scale: 4, null: false
    t.integer "stock_id", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id", "stock_id", "direction"], name: "index_holdings_on_portfolio_id_and_stock_id_and_direction", unique: true
    t.index ["portfolio_id"], name: "index_holdings_on_portfolio_id"
    t.index ["stock_id"], name: "index_holdings_on_stock_id"
  end

  create_table "idea_comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "idea_id", null: false
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["idea_id", "created_at"], name: "index_idea_comments_on_idea_id_and_created_at"
    t.index ["idea_id"], name: "index_idea_comments_on_idea_id"
    t.index ["parent_id"], name: "index_idea_comments_on_parent_id"
    t.index ["user_id"], name: "index_idea_comments_on_user_id"
  end

  create_table "idea_likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "idea_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["idea_id", "user_id"], name: "index_idea_likes_on_idea_id_and_user_id", unique: true
    t.index ["idea_id"], name: "index_idea_likes_on_idea_id"
    t.index ["user_id"], name: "index_idea_likes_on_user_id"
  end

  create_table "idea_taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "idea_id", null: false
    t.integer "idea_tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["idea_id", "idea_tag_id"], name: "index_idea_taggings_on_idea_id_and_idea_tag_id", unique: true
    t.index ["idea_id"], name: "index_idea_taggings_on_idea_id"
    t.index ["idea_tag_id"], name: "index_idea_taggings_on_idea_tag_id"
  end

  create_table "idea_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_idea_tags_on_name", unique: true
  end

  create_table "ideas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "direction", default: 0, null: false
    t.datetime "published_at"
    t.integer "stock_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["published_at"], name: "index_ideas_on_published_at"
    t.index ["stock_id"], name: "index_ideas_on_stock_id"
    t.index ["user_id", "created_at"], name: "index_ideas_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_ideas_on_user_id"
  end

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
    t.text "description"
    t.datetime "ends_at"
    t.string "invite_code"
    t.string "name"
    t.integer "owner_id", null: false
    t.decimal "starting_capital"
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_leagues_on_owner_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.integer "receiver_id", null: false
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id", "receiver_id", "created_at"], name: "index_messages_on_sender_id_and_receiver_id_and_created_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "kind", default: 0, null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "portfolio_valuations", force: :cascade do |t|
    t.decimal "cash_value", precision: 15, scale: 4, null: false
    t.datetime "created_at", null: false
    t.decimal "holdings_value", precision: 15, scale: 4, null: false
    t.integer "portfolio_id", null: false
    t.decimal "total_value", precision: 15, scale: 4, null: false
    t.datetime "updated_at", null: false
    t.datetime "valued_at", null: false
    t.index ["portfolio_id", "valued_at"], name: "index_portfolio_valuations_on_portfolio_id_and_valued_at"
    t.index ["portfolio_id"], name: "index_portfolio_valuations_on_portfolio_id"
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

  create_table "trades", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "executed_at"
    t.decimal "limit_price", precision: 12, scale: 4
    t.string "order_type", default: "market", null: false
    t.integer "portfolio_id", null: false
    t.decimal "price_at_trade"
    t.decimal "quantity"
    t.string "status", default: "filled", null: false
    t.integer "stock_id", null: false
    t.decimal "stop_loss", precision: 12, scale: 4
    t.decimal "stop_price", precision: 12, scale: 4
    t.decimal "take_profit", precision: 12, scale: 4
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_trades_on_portfolio_id"
    t.index ["stock_id"], name: "index_trades_on_stock_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "holdings", "portfolios"
  add_foreign_key "holdings", "stocks"
  add_foreign_key "idea_comments", "idea_comments", column: "parent_id"
  add_foreign_key "idea_comments", "ideas"
  add_foreign_key "idea_comments", "users"
  add_foreign_key "idea_likes", "ideas"
  add_foreign_key "idea_likes", "users"
  add_foreign_key "idea_taggings", "idea_tags"
  add_foreign_key "idea_taggings", "ideas"
  add_foreign_key "ideas", "stocks"
  add_foreign_key "ideas", "users"
  add_foreign_key "league_memberships", "leagues"
  add_foreign_key "league_memberships", "users"
  add_foreign_key "leagues", "users", column: "owner_id"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "portfolio_valuations", "portfolios"
  add_foreign_key "portfolios", "leagues"
  add_foreign_key "portfolios", "users"
  add_foreign_key "price_snapshots", "stocks"
  add_foreign_key "trades", "portfolios"
  add_foreign_key "trades", "stocks"
end
