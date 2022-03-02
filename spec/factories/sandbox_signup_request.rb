# frozen_string_literal: true

FactoryBot.define do
  factory :sandbox_signup_request, class: Hash do
    apis { '' }
    description { Faker::Hipster.word }
    email { Faker::Internet.safe_email }
    firstName { Faker::Name.first_name }
    lastName { Faker::Name.last_name }
    internalApiInfo { association :internal_sandbox_request }
    organization { Faker::Hipster.word }

    trait :generate_apis do
      after(:build) do |signup, _|
        api_one = create(:api)
        api_two = create(:api)
        signup[:apis] = "#{api_one.api_ref.name},#{api_two.api_ref.name}"
      end
    end

    initialize_with { attributes }
  end
end
