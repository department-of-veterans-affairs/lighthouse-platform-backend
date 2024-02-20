# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductionRequest, type: :model do
  subject do
    ProductionRequest.new(
      apis: [create(:api)],
      app_description: Faker::Hipster.word,
      app_name: Faker::Hipster.word,
      breach_management_process: Faker::Hipster.word,
      business_model: Faker::Hipster.word,
      centralized_backend_log: Faker::Hipster.word,
      distributing_api_keys_to_customers: false,
      expose_veteran_information_to_third_parties: false,
      is_508_compliant: true,
      listed_on_my_health_application: false,
      monitization_explanation: Faker::Hipster.word,
      monitized_veteran_information: Faker::Hipster.word,
      multiple_req_safeguards: Faker::Hipster.word,
      naming_convention: Faker::Hipster.word,
      oauth_public_key: Faker::Json.shallow_json(width: 5),
      organization: Faker::Hipster.word,
      phone_number: '(555) 555-5555',
      pii_storage_method: Faker::Hipster.word,
      platforms: Faker::Hipster.word,
      primary_contact:,
      privacy_policy_url: Faker::Internet.url,
      production_key_credential_storage: Faker::Hipster.word,
      production_or_oauth_key_credential_storage: Faker::Hipster.word,
      scopes_access_requested: Faker::Hipster.word,
      secondary_contact:,
      sign_up_link_url: Faker::Internet.url,
      status_update_emails: [Faker::Internet.safe_email],
      store_pii_or_phi: false,
      support_link_url: Faker::Internet.url,
      terms_of_service_url: Faker::Internet.url,
      third_party_info_description: Faker::Hipster.word,
      value_provided: Faker::Hipster.word,
      vasi_system_name: Faker::Hipster.word,
      veteran_facing: true,
      veteran_facing_description: Faker::Hipster.word,
      vulnerability_management: Faker::Hipster.word,
      website: Faker::Internet.url
    )
  end

  let(:user_1) { create(:user) }
  let(:primary_contact) { ProductionRequestContact.new(user: user_1, contact_type: 'primary') }

  let(:user_2) { create(:user) }
  let(:secondary_contact) { ProductionRequestContact.new(user: user_2, contact_type: 'secondary') }

  describe 'tests a valid ProductionRequest model' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it "has a 'primary_contact'" do
      expect(subject.primary_contact.user.email).to eq(user_1.email)
    end

    it "has a 'secondary_contact'" do
      expect(subject.secondary_contact.user.email).to eq(user_2.email)
    end
  end

  describe 'tests an invalid ProductionRequest model' do
    it "is invalid without an 'apis' attribute" do
      subject.apis = []
      expect(subject).not_to be_valid
    end

    it "is invalid without an 'organization' attribute" do
      subject.organization = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'primary_contact' association" do
      subject.primary_contact = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'secondary_contact' association" do
      subject.secondary_contact = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'status_update_emails' attribute" do
      subject.status_update_emails = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'value_provided' attribute" do
      subject.value_provided = nil
      expect(subject).not_to be_valid
    end
  end
end
