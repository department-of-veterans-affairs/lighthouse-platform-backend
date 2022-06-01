# frozen_string_literal: true

FactoryBot.define do
  factory :internal_sandbox_request, class: Hash do
    programName { Faker::Hipster.word }
    sponsorEmail { Faker::Internet.safe_email }
    vaEmail { Faker::Internet.safe_email }

    initialize_with { attributes }
  end
end
