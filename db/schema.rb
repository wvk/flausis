# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141215161846) do

  create_table "event_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagram_colour"
  end

  create_table "events", force: true do |t|
    t.integer  "species_id"
    t.integer  "sex_id"
    t.integer  "precipitation_id"
    t.integer  "temperature_id"
    t.integer  "event_type_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sensor_id"
    t.datetime "timestamp"
    t.boolean  "ignored"
    t.integer  "observation_session_id"
  end

  create_table "images", force: true do |t|
    t.string   "filename"
    t.string   "annotations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "timestamp"
    t.string   "path"
    t.boolean  "ignored"
    t.integer  "species_id"
    t.integer  "sex_id"
    t.integer  "precipitation_id"
    t.integer  "temperature_id"
    t.integer  "observation_session_id"
  end

  create_table "observation_sessions", force: true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "at_night"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "precipitations", force: true do |t|
    t.float    "amount"
    t.integer  "station_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "timestamp"
    t.integer  "observation_session_id"
  end

  create_table "sensors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagram_colour"
  end

  create_table "sexes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagram_colour"
  end

  create_table "species", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagram_colour"
  end

  create_table "temperatures", force: true do |t|
    t.integer  "station_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "value"
    t.datetime "timestamp"
    t.integer  "observation_session_id"
  end

end
