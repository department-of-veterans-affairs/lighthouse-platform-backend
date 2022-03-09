# frozen_string_literal: true

FactoryBot.define do
  factory :support_request, class: Hash do
    apis { '' }
    description { Faker::Lorem.sentence(word_count: 12) }
    apiDescription { Faker::Lorem.sentence(word_count: 12) }
    apiDetails { Faker::Lorem.sentence(word_count: 12) }
    apiInternalOnly { false }
    apiInternalOnlyDetails { Faker::Lorem.sentence(word_count: 12) }
    apiOtherInfo { Faker::Lorem.sentence(word_count: 12) }
    firstName { Faker::Name.first_name }
    lastName { Faker::Name.last_name }
    organization { Faker::Company.name }
    type { 'DEFAULT' }
    requester { Faker::Internet.safe_email }

    initialize_with { attributes }

    trait :set_publishing do
      after(:build) do |request, _|
        request[:type] = 'PUBLISHING'
      end
    end

    trait :set_internal_only do
      after(:build) do |request, _|
        request[:apiInternalOnly] = true
      end
    end

    trait :mock_front_end_request do
      after(:build) do |request, _|
        request.delete(:requester)
        request[:email] = Faker::Internet.safe_email
      end
    end
  end
end
