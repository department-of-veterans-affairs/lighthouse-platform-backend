# frozen_string_literal: true

FactoryBot.define do
  factory :consumer do
    description { 'MyString' }
    tos_accepted_at { '2021-07-14 12:16:18' }
    tos_version { 1 }
    organization { 'MyString' }

    trait :with_apis do
      after(:create) do |consumer, _|
        environment = FactoryBot.build(:environment)
        forms_api = FactoryBot.create(:api, :with_forms_api_ref, acl: 'va_forms', name: 'Forms API')
        claims_api = FactoryBot.create(:api, :with_claims_api_ref, acl: 'claims', name: 'Claims API')
        forms_api_environment = FactoryBot.create(:api_environment, api: forms_api, environment: environment)
        claims_api_environment = FactoryBot.create(:api_environment, api: claims_api, environment: environment)
        consumer.api_environments << forms_api_environment
        consumer.api_environments << claims_api_environment
      end
    end
  end
end
