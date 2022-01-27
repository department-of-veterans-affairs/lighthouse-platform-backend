# frozen_string_literal: true

FactoryBot.define do
  factory :api_environment do
    metadata_url { 'MyString' }
    api
    environment { Environment.find_or_create_by(name: 'sandbox') }
  end
end
