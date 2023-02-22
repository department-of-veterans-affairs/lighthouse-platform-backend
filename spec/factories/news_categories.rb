# frozen_string_literal: true

FactoryBot.define do
  factory :news_category do
    call_to_action { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    media { Faker::Boolean.boolean }
    title { Faker::Lorem.word }
    news_items { build_list :news_item, 3 }
  end
end
