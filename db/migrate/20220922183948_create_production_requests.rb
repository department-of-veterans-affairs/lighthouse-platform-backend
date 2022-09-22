class CreateProductionRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :production_requests, id: :uuid do |t|
      t.string :apis
      t.text :app_description
      t.string :app_name
      t.text :breach_management_process
      t.text :business_model
      t.string :centralized_backend_log
      t.boolean :distributing_api_keys_to_customers, default: false, null: false
      t.boolean :expose_veteran_information_to_third_parties, default: false, null: false
      t.boolean :is_508_compliant, default: false, null: false
      t.boolean :listed_on_my_health_application, default: false, null: false
      t.text :monitization_explanation
      t.boolean :monitized_veteran_information, default: false, null: false
      t.text :multiple_req_safeguards
      t.string :naming_convention
      t.string :organization
      t.string :phone_number
      t.text :pii_storage_method
      t.string :platforms
      t.string :privacy_policy_url
      t.text :production_key_credential_storage
      t.text :production_or_oauth_key_credential_storage
      t.text :scopes_access_requested
      t.string :sign_up_link_url
      t.string :status_update_emails
      t.boolean :store_pii_or_phi, default: false, null: false
      t.string :support_link_url
      t.string :terms_of_service_url
      t.text :third_party_info_description
      t.text :value_provided
      t.string :vasi_system_name
      t.boolean :veteran_facing, default: false, null: false
      t.text :veteran_facing_description
      t.text :vulnerability_management
      t.string :website

      t.timestamps
    end
  end
end
