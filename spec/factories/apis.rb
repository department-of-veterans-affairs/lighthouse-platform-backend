# frozen_string_literal: true

FactoryBot.define do
  factory :api do
    name { 'MyString' }
    acl { 'MyString' }

    trait :with_claims_api_ref do
      after(:create) do |api, _|
        api.api_ref = FactoryBot.create(:api_ref, name: 'claims')
      end
    end

    trait :with_forms_api_ref do
      after(:create) do |api, _|
        api.api_ref = FactoryBot.create(:api_ref, name: 'va_forms')
      end
    end
  end
end
