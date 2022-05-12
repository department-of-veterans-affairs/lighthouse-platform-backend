# frozen_string_literal: true

class Event < ApplicationRecord
  serialize :event

  EVENT_TYPES = { sandbox_signup: 'sandbox_signup' }.freeze

  def sandbox_signup_per_span(span)
    Event.where(event_type: EVENT_TYPES[:sandbox_signup], created_at: span)
  end
end
