# frozen_string_literal: true

FactoryBot.define do
  sequence(:unique_api_name) do |instance|
    "#{Faker::Lorem.word}#{instance}"
  end
  factory :api do
    name { generate(:unique_api_name) }
    acl { Faker::Lorem.word }
    auth_server_access_key { nil }
    api_ref { association :api_ref, api: instance }
    api_metadatum { association :api_metadatum, api: instance }

    trait :with_api_environment do
      api_environments { build_list(:api_environment, 1, api: instance) }
    end

    trait :with_lpb_ref do
      api_ref { build(:api_ref, name: 'lpb') }
      auth_server_access_key { 'AUTHZ_SERVER_LPB' }
    end

    trait :with_r34l_auth_server do
      auth_server_access_key { 'AUTHZ_SERVER_TEST_ACG' }
    end
  end
end
