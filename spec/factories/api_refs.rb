# frozen_string_literal: true

FactoryBot.define do
  factory :api_ref do
    name { Faker::Hipster.unique.word }
  end
end
