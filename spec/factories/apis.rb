# frozen_string_literal: true

FactoryBot.define do
  factory :api do
    name { 'MyString' }
    acl { 'MyString' }

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
