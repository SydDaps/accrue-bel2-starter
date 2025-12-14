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

ActiveRecord::Schema[7.2].define(version: 2025_12_13_225235) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "double_entry_account_balances", force: :cascade do |t|
    t.string "account", null: false
    t.string "scope"
    t.bigint "balance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account"], name: "index_account_balances_on_account"
    t.index ["scope", "account"], name: "index_account_balances_on_scope_and_account", unique: true
  end

  create_table "double_entry_line_checks", force: :cascade do |t|
    t.bigint "last_line_id", null: false
    t.boolean "errors_found", null: false
    t.text "log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at", "last_line_id"], name: "line_checks_created_at_last_line_id_idx"
  end

  create_table "double_entry_lines", force: :cascade do |t|
    t.string "account", null: false
    t.string "scope"
    t.string "code", null: false
    t.bigint "amount", null: false
    t.bigint "balance", null: false
    t.bigint "partner_id"
    t.string "partner_account", null: false
    t.string "partner_scope"
    t.string "detail_type"
    t.bigint "detail_id"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account", "code", "created_at"], name: "lines_account_code_created_at_idx"
    t.index ["account", "created_at"], name: "lines_account_created_at_idx"
    t.index ["scope", "account", "created_at"], name: "lines_scope_account_created_at_idx"
    t.index ["scope", "account", "id"], name: "lines_scope_account_id_idx"
  end

  create_table "gift_card_orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "gift_card_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "fee", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_card_id"], name: "index_gift_card_orders_on_gift_card_id"
    t.index ["status"], name: "index_gift_card_orders_on_status"
    t.index ["user_id"], name: "index_gift_card_orders_on_user_id"
  end

  create_table "gift_cards", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_gift_cards_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "gift_card_orders", "gift_cards"
  add_foreign_key "gift_card_orders", "users"
end
