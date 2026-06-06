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

ActiveRecord::Schema[8.1].define(version: 2026_06_06_134000) do
  create_table "partners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quote_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "quantity", null: false
    t.integer "quote_id", null: false
    t.decimal "tax_rate", null: false
    t.integer "unit_price_before_tax_in_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_id"], name: "index_quote_items_on_quote_id"
    t.check_constraint "quantity >= 0", name: "quote_items_quantity_non_negative"
    t.check_constraint "tax_rate >= 0 AND tax_rate <= 100", name: "quote_items_tax_rate_percentage_range"
    t.check_constraint "unit_price_before_tax_in_cents >= 0", name: "quote_items_unit_price_before_tax_in_cents_non_negative"
  end

  create_table "quotes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.string "name", null: false
    t.integer "partner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_quotes_on_created_by_id"
    t.index ["partner_id"], name: "index_quotes_on_partner_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "partner_id", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["partner_id"], name: "index_users_on_partner_id"
  end

  add_foreign_key "quote_items", "quotes"
  add_foreign_key "quotes", "partners"
  add_foreign_key "quotes", "users", column: "created_by_id"
  add_foreign_key "users", "partners"
end
