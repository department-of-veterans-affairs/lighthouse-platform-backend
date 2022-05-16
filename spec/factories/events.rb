# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    event_type { Faker::Lorem.unique.word }
    event { 'MyText' }

    trait :sandbox_signup do
      after(:build) do |event, _|
        event[:event_type] = Event::EVENT_TYPES[:sandbox_signup]
        event[:event] = build(:sandbox_signup_request, :mimic_event)
      end
    end
    # "./app/services/dynamo_import_service.rb",0,13,10,0,10
  end
end
