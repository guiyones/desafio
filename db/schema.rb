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

ActiveRecord::Schema[8.1].define(version: 2026_10_16_174717) do
  create_table "challenges", force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_challenges_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_groups_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.date "starts_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "slips", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.date "day", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id", "day"], name: "index_slips_on_challenge_id_and_day", unique: true
    t.index ["challenge_id"], name: "index_slips_on_challenge_id"
  end

  add_foreign_key "challenges", "groups"
  add_foreign_key "groups", "projects"
  add_foreign_key "slips", "challenges"
end
