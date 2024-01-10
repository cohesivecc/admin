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

ActiveRecord::Schema.define(version: 2016_11_10_160143) do

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.text "description"
    t.integer "position", default: 0
    t.string "locatable_type"
    t.integer "locatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locatable_type", "locatable_id"], name: "index_addresses_on_locatable_type_and_locatable_id"
  end

  create_table "cohesive_admin_users", force: :cascade do |t|
    t.string "name", limit: 40
    t.string "email", limit: 80
    t.string "password_digest"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_cohesive_admin_users_on_email"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name"
    t.integer "position", default: 0
    t.integer "people_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs_locations", id: false, force: :cascade do |t|
    t.integer "job_id"
    t.integer "location_id"
    t.index ["job_id", "location_id"], name: "index_jobs_locations_on_job_id_and_location_id"
    t.index ["job_id"], name: "index_jobs_locations_on_job_id"
    t.index ["location_id"], name: "index_jobs_locations_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "slug", limit: 20
    t.string "position", default: "0"
    t.string "image_id"
    t.text "json_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_locations_on_slug"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone_number"
    t.string "title"
    t.boolean "active"
    t.integer "address_id"
    t.text "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_managers_on_address_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "prefix"
    t.string "name"
    t.string "email"
    t.text "bio"
    t.boolean "active", default: true
    t.integer "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_people_on_job_id"
  end

end
