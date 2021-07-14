FactoryBot.define do
  factory :consumer do
    description { "MyString" }
    tos_accepted_at { "2021-07-14 12:16:18" }
    tos_version { 1 }
  end
end
