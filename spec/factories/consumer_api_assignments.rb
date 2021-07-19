FactoryBot.define do
  factory :consumer_api_assignment do
    consumer { nil }
    api { nil }
    environment { "MyString" }
    first_successful_call_at { "2021-07-15 10:40:49" }
  end
end
