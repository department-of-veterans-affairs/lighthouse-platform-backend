# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}@example.com" }
    first_name { 'MyString' }
    last_name { 'MyString' }
  end
end
