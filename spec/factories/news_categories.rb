# frozen_string_literal: true

FactoryBot.define do
  factory :news_category do
    call_to_action { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    media { Faker::Boolean.boolean }
    title { Faker::Lorem.word }
    items { association :news_item }
  end
end
