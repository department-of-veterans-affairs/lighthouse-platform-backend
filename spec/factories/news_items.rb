# frozen_string_literal: true

FactoryBot.define do
  factory :news_item do
    date { Faker::Date.between(from: 2.days.ago, to: Time.zone.today) }
    source { Faker::Lorem.sentence }
    title { Faker::Lorem.word }
    url { Faker::Internet.url }
  end
end
