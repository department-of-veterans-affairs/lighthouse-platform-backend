# frozen_string_literal: true

FactoryBot.define do
  factory :test_user_email do
    email { Faker::Internet.email }
    claims { Faker::Boolean.boolean }
    communityCare { Faker::Boolean.boolean }
    health { Faker::Boolean.boolean }
    verification { Faker::Boolean.boolean }
  end
end
