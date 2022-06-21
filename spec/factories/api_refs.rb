# frozen_string_literal: true

FactoryBot.define do
  sequence(:unique_category_key) do |instance|
    "#{Faker::Space.planet}#{instance}"
  end

  factory :api_ref do
    name { generate(:unique_category_key) }
  end
end
