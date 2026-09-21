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

ActiveRecord::Schema[8.1].define(version: 2026_09_21_062958) do
  create_table "activity_logs", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.integer "record_id"
    t.string "record_type"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["action"], name: "index_activity_logs_on_action"
    t.index ["created_at"], name: "index_activity_logs_on_created_at"
    t.index ["record_type", "record_id"], name: "index_activity_logs_on_record_type_and_record_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "inventory_code", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_devices_on_active"
    t.index ["category"], name: "index_devices_on_category"
    t.index ["inventory_code"], name: "index_devices_on_inventory_code", unique: true
  end

  create_table "loans", force: :cascade do |t|
    t.datetime "borrowed_at", null: false
    t.datetime "created_at", null: false
    t.integer "device_id", null: false
    t.text "notes"
    t.datetime "returned_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["device_id"], name: "idx_unique_active_loan_per_device", unique: true, where: "returned_at IS NULL"
    t.index ["device_id"], name: "index_loans_on_device_id"
    t.index ["returned_at"], name: "index_loans_on_returned_at"
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "activity_logs", "users"
  add_foreign_key "loans", "devices"
  add_foreign_key "loans", "users"
end
