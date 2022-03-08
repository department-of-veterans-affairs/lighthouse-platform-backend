# frozen_string_literal: true

FactoryBot.define do
  factory :api_release_note do
    date { Faker::Date.between(from: 2.days.ago, to: Time.zone.today) }
    content { Faker::Markdown.random }
  end
end
