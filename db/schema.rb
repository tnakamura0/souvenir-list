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

ActiveRecord::Schema[8.1].define(version: 2026_07_31_114504) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "recipient_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "recipient_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id", "tag_id"], name: "index_recipient_tags_on_recipient_id_and_tag_id", unique: true
    t.index ["recipient_id"], name: "index_recipient_tags_on_recipient_id"
    t.index ["tag_id"], name: "index_recipient_tags_on_tag_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", default: "individual", null: false
    t.text "memo"
    t.string "name", null: false
    t.integer "people_count", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_recipients_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "trip_recipients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "purchased", default: false, null: false
    t.bigint "recipient_id", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_trip_recipients_on_recipient_id"
    t.index ["trip_id", "recipient_id"], name: "index_trip_recipients_on_trip_id_and_recipient_id", unique: true
    t.index ["trip_id"], name: "index_trip_recipients_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "departure_date", null: false
    t.string "destination", null: false
    t.string "name", null: false
    t.date "return_date", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "google_uid", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "recipient_tags", "recipients"
  add_foreign_key "recipient_tags", "tags"
  add_foreign_key "recipients", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "trip_recipients", "recipients"
  add_foreign_key "trip_recipients", "trips"
  add_foreign_key "trips", "users"
end
