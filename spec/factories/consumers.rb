# frozen_string_literal: true

FactoryBot.define do
  factory :consumer do
    description { 'MyString' }
    tos_accepted_at { '2021-07-14 12:16:18' }
    tos_version { 1 }
    organization { 'MyString' }

    trait :with_apis do
      after(:create) do |consumer, _|
        consumer.apis << FactoryBot.create(:api, acl: 'claims', name: 'Claims API')
        consumer.apis << FactoryBot.create(:api, acl: 'va_forms', name: 'Forms API')
      end
    end
  end
end
