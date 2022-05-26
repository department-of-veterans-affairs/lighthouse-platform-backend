# frozen_string_literal: true

class Event < ApplicationRecord
  validates :event_type, presence: true
  validates :content, presence: true

  EVENT_TYPES = { sandbox_signup: 'sandbox_signup' }.freeze
end
