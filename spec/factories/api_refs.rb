# frozen_string_literal: true

FactoryBot.define do
  sequence(:unique_ref_name) do |instance|
    "#{Faker::Space.planet}#{instance}"
  end

  factory :api_ref do
    name { generate(:unique_ref_name) }
  end
end
