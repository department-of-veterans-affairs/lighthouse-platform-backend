# frozen_string_literal: true

FactoryBot.define do
  factory :api do
    name { Faker::Hipster.word }
    acl { Faker::Hipster.word }
    auth_server_access_key { Faker::Hipster.word }
    api_ref { association :api_ref, api: instance }

    trait :with_claims_api_ref do
      after(:create) do |api, _|
        FactoryBot.create(:api_ref, name: 'claims', api_id: api.id)
        FactoryBot.build(:api_environment)
      end
    end

    trait :with_forms_api_ref do
      after(:create) do |api, _|
        FactoryBot.create(:api_ref, name: 'va_forms', api_id: api.id)
        FactoryBot.build(:api_environment)
      end
    end
  end
end
