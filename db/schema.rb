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

ActiveRecord::Schema[7.0].define(version: 2024_03_14_152200) do
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
    t.string "url_slug"
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
    t.string "veteran_redirect_link_url"
    t.string "veteran_redirect_link_text"
    t.string "veteran_redirect_message"
    t.text "overview_page_content"
    t.text "restricted_access_details"
    t.boolean "restricted_access_toggle"
    t.string "url_slug"
    t.boolean "block_sandbox_form", default: false
    t.boolean "is_stealth_launched", default: true
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

  create_table "apis_production_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "api_id", null: false
    t.uuid "production_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_id"], name: "index_apis_production_requests_on_api_id"
    t.index ["production_request_id"], name: "index_apis_production_requests_on_production_request_id"
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

  create_table "news_categories", force: :cascade do |t|
    t.string "call_to_action"
    t.string "description"
    t.string "media"
    t.string "title"
  end

  create_table "news_items", force: :cascade do |t|
    t.bigint "news_category_id"
    t.string "date"
    t.string "source"
    t.string "title"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["news_category_id"], name: "index_news_items_on_news_category_id"
  end

  create_table "production_request_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "production_request_id", null: false
    t.bigint "user_id", null: false
    t.integer "contact_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["production_request_id"], name: "index_production_request_contacts_on_production_request_id"
    t.index ["user_id"], name: "index_production_request_contacts_on_user_id"
  end

  create_table "production_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "app_description"
    t.string "app_name"
    t.text "breach_management_process"
    t.text "business_model"
    t.string "centralized_backend_log"
    t.boolean "distributing_api_keys_to_customers", default: false, null: false
    t.boolean "expose_veteran_information_to_third_parties", default: false, null: false
    t.boolean "is_508_compliant", default: false, null: false
    t.boolean "listed_on_my_health_application", default: false, null: false
    t.text "monitization_explanation"
    t.boolean "monitized_veteran_information", default: false, null: false
    t.text "multiple_req_safeguards"
    t.string "naming_convention"
    t.string "organization"
    t.string "phone_number"
    t.text "pii_storage_method"
    t.string "platforms"
    t.string "privacy_policy_url"
    t.text "production_key_credential_storage"
    t.text "production_or_oauth_key_credential_storage"
    t.text "scopes_access_requested"
    t.string "sign_up_link_url"
    t.string "status_update_emails"
    t.boolean "store_pii_or_phi", default: false, null: false
    t.string "support_link_url"
    t.string "terms_of_service_url"
    t.text "third_party_info_description"
    t.text "value_provided"
    t.string "vasi_system_name"
    t.boolean "veteran_facing", default: false, null: false
    t.text "veteran_facing_description"
    t.text "vulnerability_management"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_icon"
    t.string "logo_large"
    t.string "oauth_application_type"
    t.jsonb "oauth_public_key"
    t.string "oauth_redirect_uri"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "city"
    t.string "country"
    t.string "state"
    t.string "zip_code_5"
    t.boolean "attestation_checked"
  end

  create_table "sitemap_urls", force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_user_emails", force: :cascade do |t|
    t.text "email", null: false
    t.boolean "claims", default: false, null: false
    t.boolean "communityCare", default: false, null: false
    t.boolean "health", default: false, null: false
    t.boolean "verification", default: false, null: false
    t.index ["email"], name: "index_test_user_emails_on_email", unique: true
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
  add_foreign_key "apis_production_requests", "apis"
  add_foreign_key "apis_production_requests", "production_requests"
  add_foreign_key "consumer_api_assignments", "consumers"
  add_foreign_key "consumer_auth_refs", "consumers"
  add_foreign_key "consumers", "users"
  add_foreign_key "news_items", "news_categories"
  add_foreign_key "production_request_contacts", "production_requests"
  add_foreign_key "production_request_contacts", "users"
end
