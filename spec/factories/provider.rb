# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: Hash do
    name { Faker::Lorem.word }
    auth_server_access_key { Faker::Lorem.word }
    api_environments_attributes do
      {
        metadata_url: Faker::Internet.domain_name,
        environments_attributes: {
          name: 'sandbox,production'
        }
      }
    end
    api_ref_attributes do
      {
        name: Faker::Lorem.word
      }
    end
    api_metadatum_attributes do
      {
        description: Faker::Lorem.sentence(word_count: 12),
        display_name: Faker::Lorem.sentence(word_count: 4),
        open_data: Faker::Boolean.boolean,
        va_internal_only: [nil, 'StrictlyInternal', 'AdditionalDetails', 'FlagOnly'].sample,
        url_fragment: Faker::Lorem.word,
        oauth_info: {
          ccgInfo: {
            baseAuthPath: Faker::Internet.domain_name,
            productionAud: Faker::Lorem.word,
            productionWellKnownConfig: Faker::Internet.url,
            sandboxAud: Faker::Lorem.word,
            sandboxWellKnownConfig: Faker::Internet.url,
            scopes: 'test.true,test.false'
          },
          acgInfo: {
            baseAuthPath: Faker::Internet.domain_name,
            productionWellKnownConfig: Faker::Internet.url,
            sandboxWellKnownConfig: Faker::Internet.url,
            scopes: 'test.true,test.false'
          }
        },
        api_category_attributes: {
          id: ApiCategory.first.id || nil
        }
      }
    end

    initialize_with { attributes }
  end
end
