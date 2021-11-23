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

ActiveRecord::Schema.define(version: 2021_11_18_234650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_environments", force: :cascade do |t|
    t.bigint "api_id"
    t.bigint "environment_id"
    t.string "metadata_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_id"], name: "index_api_environments_on_api_id"
    t.index ["environment_id"], name: "index_api_environments_on_environment_id"
  end

  create_table "api_refs", force: :cascade do |t|
    t.string "name"
    t.bigint "api_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_id"], name: "index_api_refs_on_api_id"
  end

  create_table "apis", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.string "acl"
    t.index ["discarded_at"], name: "index_apis_on_discarded_at"
  end

  create_table "consumer_api_assignments", force: :cascade do |t|
    t.bigint "consumer_id", null: false
    t.bigint "api_id", null: false
    t.datetime "first_successful_call_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["api_id"], name: "index_consumer_api_assignments_on_api_id"
    t.index ["consumer_id"], name: "index_consumer_api_assignments_on_consumer_id"
    t.index ["discarded_at"], name: "index_consumer_api_assignments_on_discarded_at"
  end

  create_table "consumers", force: :cascade do |t|
    t.string "description"
    t.datetime "tos_accepted_at"
    t.integer "tos_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sandbox_gateway_ref"
    t.string "sandbox_oauth_ref"
    t.string "prod_gateway_ref"
    t.string "prod_oauth_ref"
    t.bigint "user_id", null: false
    t.string "organization"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_consumers_on_discarded_at"
    t.index ["user_id"], name: "index_consumers_on_user_id"
  end

  create_table "environments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "user"
    t.datetime "discarded_at"
    t.string "provider", limit: 50, default: "", null: false
    t.string "uid", limit: 50, default: "", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "api_environments", "apis"
  add_foreign_key "api_environments", "environments"
  add_foreign_key "api_refs", "apis"
  add_foreign_key "consumer_api_assignments", "apis"
  add_foreign_key "consumer_api_assignments", "consumers"
  add_foreign_key "consumers", "users"
end
