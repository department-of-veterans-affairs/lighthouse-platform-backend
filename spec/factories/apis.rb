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
  end
end
