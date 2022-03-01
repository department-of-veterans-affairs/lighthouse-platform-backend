# frozen_string_literal: true

FactoryBot.define do
  factory :okta_consumer, class: Hash do
    id { Faker::Internet.uuid }
    name { 'oidc_client' }
    label { Faker::Name.first_name }
    credentials do
      { oauthClient:
        {
          client_id: Faker::Internet.uuid,
          client_secret: Faker::Internet.uuid
        } }
    end
    settings do
      {
        oauthClient: {
          redirect_uris:
            [Faker::Internet.url(path: '/callback'),
             Faker::Internet.url(path: '/oauth2/redirect/')]
        }
      }
    end

    initialize_with { attributes }
  end
end
