# frozen_string_literal: true

FactoryBot.define do
  factory :malicious_url do
    url { Faker::Internet.url }
  end
end
