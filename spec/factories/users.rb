FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}@example.com" }
    first_name { 'MyString' }
    last_name { 'MyString' }
    organization { 'MyString' }
  end
end
