FactoryBot.define do
  factory :sitemap_url do
    url { Faker::Internet.url }
  end
end
