# frozen_string_literal: true

FactoryBot.define do
  factory :consumer do
    description { 'MyString' }
    tos_accepted_at { '2021-07-14 12:16:18' }
    tos_version { 1 }
    organization { 'MyString' }

    trait :with_apis do
      after(:create) do |consumer, _|
        environment = FactoryBot.create(:environment, name: 'test')

        claims_api = FactoryBot.create(:api, :with_claims_api_ref, acl: 'claims', name: 'Claims API')
        forms_api = FactoryBot.create(:api, :with_forms_api_ref, acl: 'va_forms', name: 'Forms API')

        api_env_one = FactoryBot.create(:api_environment, api: claims_api, environment: environment)
        api_env_two = FactoryBot.create(:api_environment, api: forms_api, environment: environment)
        consumer.consumer_api_assignments << FactoryBot.create(:consumer_api_assignment, consumer: consumer,
                                                                                         api_environment: api_env_one)
        consumer.consumer_api_assignments << FactoryBot.create(:consumer_api_assignment, consumer: consumer,
                                                                                         api_environment: api_env_two)

        facilities_api = FactoryBot.create(:api, name: 'facilities', acl: 'facilities')
        FactoryBot.create(:api_ref, name: 'facilities', api_id: facilities_api.id)
        FactoryBot.create(:api_environment, api: facilities_api, environment: environment)
      end
    end
  end
end
