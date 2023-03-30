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

    trait :with_auth_server do
      acl { nil }
      auth_server_access_key { 'PROVIDER' }
    end

    trait :no_acl do
      acl { nil }
    end

    trait :no_acg do
      api_metadatum { build(:api_metadatum, :without_acg) }
    end

    trait :no_ccg do
      api_metadatum { build(:api_metadatum, :without_ccg) }
    end

    factory :api_without_acl, traits: [:no_acl]
    factory :api_without_acg, traits: [:no_acg]
    factory :api_without_ccg, traits: [:no_ccg]
  end
end
