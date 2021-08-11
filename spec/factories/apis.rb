# frozen_string_literal: true

FactoryBot.define do
  factory :api do
    name { 'MyString' }
    auth_method { 'MyString' }
    environment { 'sandbox' }
    open_api_url { 'MyString' }
    base_path { 'MyString' }
    sequence(:service_ref) { |n| "#{n}-ref" }
  end
end
