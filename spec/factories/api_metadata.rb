# frozen_string_literal: true

FactoryBot.define do
  factory :api_metadatum do
    description { Faker::Lorem.sentence }
    display_name { "#{Faker::JapaneseMedia::Naruto.character} API" }
    open_data { Faker::Boolean.boolean }
    va_internal_only { [nil, 'StrictlyInternal', 'AdditionalDetails', 'FlagOnly'].sample }
    url_fragment { Faker::Lorem.word }
    overview_page_content { Faker::Lorem.sentence }
    restricted_access_details { Faker::Lorem.sentence }
    restricted_access_toggle { false }
    url_slug { Faker::Lorem.word }
    block_sandbox_form { false }
    oauth_info do
      {
        acgInfo: {
          baseAuthPath: "/oauth2/#{Faker::Lorem.word}/v1",
          productionWellKnownConfig: Faker::Internet.url,
          sandboxWellKnownConfig: Faker::Internet.url,
          productionAud: Faker::Internet.slug,
          sandboxAud: Faker::Internet.slug,
          scopes: Faker::Lorem.words(number: 5)
        },
        ccgInfo: {
          baseAuthPath: "/oauth2/#{Faker::Lorem.word}/system/v1",
          productionAud: Faker::Internet.slug,
          productionWellKnownConfig: Faker::Internet.url,
          sandboxAud: Faker::Internet.slug,
          sandboxWellKnownConfig: Faker::Internet.url,
          scopes: Faker::Lorem.words(number: 2)
        }
      }.to_json
    end
    api_category { association :api_category }
    api_release_notes { build_list :api_release_note, 3 }

    trait :without_acg do
      oauth_info do
        {
          ccgInfo: {
            baseAuthPath: "/oauth2/#{Faker::Lorem.word}/system/v1",
            productionAud: Faker::Internet.slug,
            productionWellKnownConfig: Faker::Internet.url,
            sandboxAud: Faker::Internet.slug,
            sandboxWellKnownConfig: Faker::Internet.url,
            scopes: Faker::Lorem.words(number: 2)
          }
        }.to_json
      end
    end

    trait :without_ccg do
      oauth_info do
        {
          acgInfo: {
            baseAuthPath: "/oauth2/#{Faker::Lorem.word}/v1",
            productionWellKnownConfig: Faker::Internet.url,
            sandboxWellKnownConfig: Faker::Internet.url,
            productionAud: Faker::Internet.slug,
            sandboxAud: Faker::Internet.slug,
            scopes: Faker::Lorem.words(number: 5)
          }
        }.to_json
      end
    end
  end
end
