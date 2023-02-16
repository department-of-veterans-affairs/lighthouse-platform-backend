# frozen_string_literal: true

FactoryBot.define do
  factory :news do
    call_to_action { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    media { Faker::Boolean.boolean }
    title { Faker::Lorem.word }
    news_items { association :news_items }
  end
end
