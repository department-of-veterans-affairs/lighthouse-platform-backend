# frozen_string_literal: true

FactoryBot.define do
  sequence(:unique_event_type) do |instance|
    "#{Faker::Lorem.word}#{instance}"
  end

  factory :event do
    event_type { generate(:unique_event_type) }
    content { 'MyText' }

    trait :sandbox_signup do
      after(:build) do |event, _|
        event[:event_type] = Event::EVENT_TYPES[:sandbox_signup]
        event[:content] = build(:sandbox_signup_request, :mimic_event)
      end
    end
  end
end
