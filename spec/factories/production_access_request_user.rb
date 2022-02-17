# frozen_string_literal: true

FactoryBot.define do
  factory :production_access_request_user, class: Hash do
    email { Faker::Internet.safe_email }
    firstName { Faker::Name.first_name }
    lastName { Faker::Name.first_name }

    initialize_with { attributes }
  end
end
