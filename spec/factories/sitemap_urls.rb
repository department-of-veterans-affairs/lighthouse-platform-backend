# frozen_string_literal: true

FactoryBot.define do
  factory :sitemap_url do
    url { Faker::Internet.url }
  end
end
