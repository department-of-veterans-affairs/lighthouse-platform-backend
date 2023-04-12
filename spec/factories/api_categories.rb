# frozen_string_literal: true

FactoryBot.define do
  sequence(:unique_category_key) do |instance|
    "#{Faker::Lorem.word}#{instance}"
  end

  factory :api_category do
    name { Faker::JapaneseMedia::Naruto.village }
    key { generate(:unique_category_key) }
    short_description { Faker::Lorem.sentence }
    consumer_docs_link_text { Faker::Lorem.sentence }
    veteran_redirect_link_url { Faker::Internet.url }
    veteran_redirect_link_text { Faker::Lorem.sentence }
    veteran_redirect_message { Faker::Lorem.sentence }
    overview { Faker::Lorem.paragraph }
    url_slug { Faker::Lorem.word }
  end
end
