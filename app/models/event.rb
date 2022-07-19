# frozen_string_literal: true

class Event < ApplicationRecord
  validates :event_type, presence: true
  validates :content, presence: true

  EVENT_TYPES = { sandbox_signup: 'sandbox_signup',
                  weekly_report: 'weekly_signups_report',
                  monthly_report: 'monthly_signups_report',
                  lpb_signup: 'lpb_signup',
                  drift_job: 'drift_job' }.freeze
end
