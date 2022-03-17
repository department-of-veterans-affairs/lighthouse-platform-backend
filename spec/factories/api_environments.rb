# frozen_string_literal: true

FactoryBot.define do
  factory :api_environment do
    metadata_url { 'MyString' }
    api
    environment { Environment.find_or_create_by(name: 'sandbox') }

    trait :auth_server_access_key do
      after(:create) do |api_env, _|
        api = api_env.api
        api[:acl] = nil
        api[:auth_server_access_key] = Faker::Hipster.word
        api.save!
      end
    end
  end
end
