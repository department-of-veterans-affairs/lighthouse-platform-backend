# frozen_string_literal: true

FactoryBot.define do
  factory :api_metadatum do
    description { Faker::Lorem.sentence }
    display_name { "#{Faker::JapaneseMedia::Naruto.character} API" }
    open_data { Faker::Boolean.boolean }
    va_internal_only { Faker::Boolean.boolean }
    url_fragment { Faker::Lorem.word }
    oauth_info do
      {
        acgInfo: {
          baseAuthPath: "/oauth2/#{Faker::Lorem.word}/v1",
          scopes: Faker::Lorem.words(number: 5)
        },
        ccgInfo: {
          baseAuthPath: "/oauth2/#{Faker::Lorem.word}/system/v1",
          productionAud: Faker::Internet.slug,
          sandboxAud: Faker::Internet.slug,
          scopes: Faker::Lorem.words(number: 2)
        }
      }.to_json
    end
    api_category { association :api_category }
  end
end
