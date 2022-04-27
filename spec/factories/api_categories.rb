# frozen_string_literal: true

FactoryBot.define do
  factory :api_category do
    name { Faker::JapaneseMedia::Naruto.village }
    key { Faker::Lorem.unique.word }
    short_description { Faker::Lorem.sentence }
    consumer_docs_link_text { Faker::Lorem.sentence }
    veteran_redirect_link_url { Faker::Internet.url }
    veteran_redirect_link_text { Faker::Lorem.sentence }
    veteran_redirect_message { Faker::Lorem.sentence }
    overview { Faker::Lorem.paragraph }
  end
end
