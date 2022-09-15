# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}@example.com" }
    first_name { 'MyString' }
    last_name { 'MyString' }

    trait :with_dougs_email do
      before(:create) do |user, _|
        user.email = 'doug@douglas.funnie.org'
      end
    end
  end
end
