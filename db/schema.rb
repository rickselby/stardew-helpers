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

ActiveRecord::Schema[7.2].define(version: 2023_12_06_143218) do
  create_table "locations", force: :cascade do |t|
    t.string "map"
    t.integer "x"
    t.integer "y"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "person_schedules", force: :cascade do |t|
    t.integer "person_id", null: false
    t.string "season"
    t.integer "day"
    t.integer "order"
    t.integer "schedule_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_person_schedules_on_person_id"
    t.index ["schedule_id"], name: "index_person_schedules_on_schedule_id"
  end

  create_table "schedule_locations", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.integer "order"
    t.integer "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time"
    t.boolean "arrival_time", default: false, null: false
    t.index ["location_id"], name: "index_schedule_locations_on_location_id"
    t.index ["schedule_id"], name: "index_schedule_locations_on_schedule_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rain", default: false, null: false
  end

  add_foreign_key "person_schedules", "people"
  add_foreign_key "person_schedules", "schedules"
  add_foreign_key "schedule_locations", "locations"
  add_foreign_key "schedule_locations", "schedules"
end
