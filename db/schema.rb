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

ActiveRecord::Schema[7.0].define(version: 2022_08_16_194252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "consumer_docs_link_text"
    t.string "short_description"
    t.text "quickstart"
    t.string "veteran_redirect_link_url"
    t.string "veteran_redirect_link_text"
    t.string "veteran_redirect_message"
    t.text "overview"
    t.string "key"
    t.index ["discarded_at"], name: "index_api_categories_on_discarded_at"
    t.index ["key"], name: "index_api_categories_on_key", unique: true
  end

  create_table "api_environments", force: :cascade do |t|
    t.bigint "api_id"
    t.bigint "environment_id"
    t.string "metadata_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at", precision: nil
    t.index ["api_id"], name: "index_api_environments_on_api_id"
    t.index ["discarded_at"], name: "index_api_environments_on_discarded_at"
    t.index ["environment_id"], name: "index_api_environments_on_environment_id"
  end

  create_table "api_metadata", force: :cascade do |t|
    t.bigint "api_id"
    t.string "description"
    t.string "display_name"
    t.boolean "open_data"
    t.jsonb "oauth_info"
    t.bigint "api_category_id"
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url_fragment"
    t.jsonb "deactivation_info"
    t.string "va_internal_only"
    t.index ["api_category_id"], name: "index_api_metadata_on_api_category_id"
    t.index ["api_id"], name: "index_api_metadata_on_api_id"
    t.index ["discarded_at"], name: "index_api_metadata_on_discarded_at"
  end

  create_table "api_refs", force: :cascade do |t|
    t.string "name"
    t.bigint "api_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at", precision: nil
    t.index ["api_id"], name: "index_api_refs_on_api_id"
    t.index ["discarded_at"], name: "index_api_refs_on_discarded_at"
  end

  create_table "api_release_notes", force: :cascade do |t|
    t.bigint "api_metadatum_id"
    t.date "date"
    t.text "content"
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_metadatum_id"], name: "index_api_release_notes_on_api_metadatum_id"
    t.index ["discarded_at"], name: "index_api_release_notes_on_discarded_at"
  end

  create_table "apis", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at", precision: nil
    t.string "acl"
    t.string "auth_server_access_key"
    t.index ["discarded_at"], name: "index_apis_on_discarded_at"
    t.index ["name"], name: "index_apis_on_name", unique: true
  end

  create_table "background_job_enforcers", force: :cascade do |t|
    t.string "job_type"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_type", "date"], name: "index_background_job_enforcers_on_job_type_and_date", unique: true
  end

  create_table "consumer_api_assignments", force: :cascade do |t|
    t.bigint "consumer_id", null: false
    t.datetime "first_successful_call_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at", precision: nil
    t.bigint "api_environment_id"
    t.index ["api_environment_id"], name: "index_consumer_api_assignments_on_api_environment_id"
    t.index ["consumer_id"], name: "index_consumer_api_assignments_on_consumer_id"
    t.index ["discarded_at"], name: "index_consumer_api_assignments_on_discarded_at"
  end

  create_table "consumer_auth_refs", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.bigint "consumer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["consumer_id"], name: "index_consumer_auth_refs_on_consumer_id"
    t.index ["discarded_at"], name: "index_consumer_auth_refs_on_discarded_at"
  end

  create_table "consumers", force: :cascade do |t|
    t.string "description"
    t.datetime "tos_accepted_at", precision: nil
    t.integer "tos_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "organization"
    t.datetime "discarded_at", precision: nil
    t.boolean "unsubscribe", default: false
    t.index ["discarded_at"], name: "index_consumers_on_discarded_at"
    t.index ["user_id"], name: "index_consumers_on_user_id"
  end

  create_table "environments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at", precision: nil
    t.index ["discarded_at"], name: "index_environments_on_discarded_at"
  end

  create_table "events", force: :cascade do |t|
    t.string "event_type", null: false
    t.jsonb "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "malicious_urls", force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_malicious_urls_on_url", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "user"
    t.string "provider", limit: 50, default: "", null: false
    t.string "uid", limit: 50, default: "", null: false
    t.datetime "discarded_at", precision: nil
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "api_environments", "apis"
  add_foreign_key "api_environments", "environments"
  add_foreign_key "api_metadata", "api_categories"
  add_foreign_key "api_metadata", "apis"
  add_foreign_key "api_refs", "apis"
  add_foreign_key "api_release_notes", "api_metadata"
  add_foreign_key "consumer_api_assignments", "consumers"
  add_foreign_key "consumer_auth_refs", "consumers"
  add_foreign_key "consumers", "users"
end
