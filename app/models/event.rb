# frozen_string_literal: true

class Event < ApplicationRecord
  validates :event_type, presence: true
  validates :content, presence: true
  scope :timeframe, ->(timeframe) { where(created_at: timeframe) }

  EVENT_TYPES = { sandbox_signup: 'sandbox_signup' }.freeze

  def include_api?(ref)
    content['apis'].split(',').include?(ref) if content['apis'].present?
  end
end
