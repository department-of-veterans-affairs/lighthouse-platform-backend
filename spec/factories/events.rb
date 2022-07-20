# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    event_type { Event::EVENT_TYPES.values.sample }
    content { 'MyText' }

    trait :sandbox_signup do
      after(:build) do |event, _|
        event[:event_type] = Event::EVENT_TYPES[:sandbox_signup]
        event[:content] = build(:sandbox_signup_request, :mimic_event)
      end
    end
  end
end
