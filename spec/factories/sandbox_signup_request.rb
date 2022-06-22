# frozen_string_literal: true

FactoryBot.define do
  sequence(:unique_organization_name) do |instance|
    "#{Faker::Team.creature}#{instance}"
  end

  factory :sandbox_signup_request, class: Hash do
    apis { '' }
    description { Faker::Team.creature }
    email { Faker::Internet.safe_email }
    firstName { Faker::Name.first_name }
    lastName { Faker::Name.last_name }
    internalApiInfo { association :internal_sandbox_request }
    organization { generate(:unique_organization_name) }

    trait :generate_apis_after_parse do
      after(:build) do |signup, _|
        signup[:apis] = create_list(:api, 2)
      end
    end

    trait :mimic_event do
      after(:build) do |signup, _|
        signup['email'] = Faker::Internet.safe_email
        signup['apis'] = create_list(:api, 2).map(&:api_ref).map(&:name).join(',')
      end
    end

    initialize_with { attributes }
  end
end
