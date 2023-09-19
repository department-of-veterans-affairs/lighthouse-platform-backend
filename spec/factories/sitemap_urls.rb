FactoryBot.define do
  factory :news_item do
    url { Faker::Internet.url }
  end
end
