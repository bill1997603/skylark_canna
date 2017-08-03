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

ActiveRecord::Schema.define(version: 20170727052951) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assigns", force: :cascade do |t|
    t.integer "problem_id"
    t.integer "paper_id"
    t.decimal "problem_score", default: "5.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paper_id"], name: "index_assigns_on_paper_id"
    t.index ["problem_id"], name: "index_assigns_on_problem_id"
  end

  create_table "enrolls", force: :cascade do |t|
    t.integer "user_id"
    t.integer "paper_id"
    t.datetime "hand_in_time"
    t.decimal "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "chosen_list", default: [], array: true
    t.index ["paper_id"], name: "index_enrolls_on_paper_id"
    t.index ["user_id"], name: "index_enrolls_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.text "description"
    t.boolean "right", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "problem_id"
    t.index ["problem_id"], name: "index_options_on_problem_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "remote_updated_at"
    t.string "ancestry"
    t.integer "children_count"
    t.index ["ancestry"], name: "index_organizations_on_ancestry"
    t.index ["uid"], name: "index_organizations_on_uid"
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.index ["user_id", "organization_id"], name: "index_organizations_users_on_user_id_and_organization_id"
  end

  create_table "papers", force: :cascade do |t|
    t.integer "scale", default: 1
    t.datetime "deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.boolean "trashed", default: false
    t.string "code"
  end

  create_table "problems", force: :cascade do |t|
    t.text "description"
    t.integer "form", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
  end

  create_table "problems_tags", id: false, force: :cascade do |t|
    t.bigint "problem_id", null: false
    t.bigint "tag_id", null: false
    t.index ["problem_id", "tag_id"], name: "index_problems_tags_on_problem_id_and_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "openid"
    t.datetime "remote_updated_at"
    t.integer "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
