# frozen_string_literal: true

FactoryBot.define do
  factory :api do
    name { Faker::Hipster.word }
    acl { Faker::Hipster.word }
    auth_server_access_key { nil }
    api_ref { association :api_ref, api: instance }
    api_metadatum { association :api_metadatum, api: instance }
  end
end
