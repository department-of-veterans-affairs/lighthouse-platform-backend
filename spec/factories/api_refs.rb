# frozen_string_literal: true

FactoryBot.define do
  factory :api_ref do
    name { Faker::Space.planet }
  end
end
