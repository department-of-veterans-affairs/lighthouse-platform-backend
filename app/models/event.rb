# frozen_string_literal: true

class Event < ApplicationRecord
  validates :event_type, presence: true
  validates :content, presence: true
  serialize :content
  scope :timeframe, ->(span) { where(created_at: span) }

  EVENT_TYPES = { sandbox_signup: 'sandbox_signup' }.freeze
end
