# frozen_string_literal: true

FactoryBot.define do
  factory :kong_consumer, class: Hash do
    kong_id { Faker::Internet.uuid }
    kong_username { Faker::Name.first_name }
    token { Faker::Internet.uuid }

    initialize_with { attributes }
  end
end
