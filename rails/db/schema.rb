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

ActiveRecord::Schema.define(version: 2021_12_28_001244) do

  create_table "authorizations", force: :cascade do |t|
    t.string "provider", null: false
    t.bigint "uid", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_authorizations_on_uid"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "highlights", force: :cascade do |t|
    t.text "content"
    t.text "attachments"
    t.bigint "author_id", null: false
    t.datetime "timestamp", null: false
    t.boolean "deleted", null: false
    t.bigint "msg_id", null: false
    t.bigint "channel_id", null: false
    t.bigint "server_id", null: false
    t.bigint "highlight_msg_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issues", force: :cascade do |t|
    t.text "content", null: false
    t.integer "category", default: 0, null: false
    t.text "status", default: "new", null: false
    t.bigint "user_id", null: false
    t.bigint "server_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "linkeds", force: :cascade do |t|
    t.text "category"
    t.text "url"
    t.datetime "timestamp"
    t.text "file_hash"
    t.bigint "author_id"
    t.bigint "server_id"
    t.bigint "channel_id"
    t.bigint "msg_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "datetime", null: false
    t.text "message"
    t.bigint "user_id", null: false
    t.bigint "channel_id"
    t.bigint "repeat", default: 0
    t.bigint "parent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "triggers", force: :cascade do |t|
    t.text "phrase", null: false
    t.text "reply"
    t.text "file"
    t.bigint "user_id", null: false
    t.bigint "server_id", null: false
    t.integer "chance", default: 0
    t.integer "mode", default: 0
    t.bigint "occurrences", default: 0, null: false
    t.bigint "calls", default: 0, null: false
    t.datetime "last_triggered"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trophies", force: :cascade do |t|
    t.text "reason", null: false
    t.integer "duration", null: false
    t.integer "category", default: 0, null: false
    t.bigint "discord_uid", null: false
    t.bigint "server_id", null: false
    t.bigint "role_id", null: false
    t.boolean "expired", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "discriminator"
    t.string "avatar"
    t.string "locale"
    t.datetime "birthday"
    t.integer "permissions"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "last_congratulation", default: 0, null: false
    t.index ["name"], name: "index_users_on_name"
  end

end
