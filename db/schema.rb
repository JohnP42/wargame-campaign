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

ActiveRecord::Schema.define(version: 20160327061145) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "armies", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_current",  default: false
  end

  create_table "battalions", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "is_building"
    t.string   "data"
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.float    "movement",    default: 0.0
  end

  add_index "battalions", ["user_id"], name: "index_battalions_on_user_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "map_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "turn"
    t.string   "white_list"
  end

  add_index "campaigns", ["map_id"], name: "index_campaigns_on_map_id", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "maps", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "tileset"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "combatType",  default: "Infantry"
    t.integer  "price",       default: 10
    t.integer  "tier",        default: 1
    t.boolean  "hero",        default: true
    t.integer  "army_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "units", ["army_id"], name: "index_units_on_army_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",                    null: false
    t.string   "email",                       null: false
    t.string   "password_digest"
    t.integer  "campaign_id"
    t.integer  "gold",            default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "users", ["campaign_id"], name: "index_users_on_campaign_id", using: :btree

end
