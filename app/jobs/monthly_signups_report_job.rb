# frozen_string_literal: true

class MonthlySignupsReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    return unless Flipper.enabled?(:alert_signups_report)

    signup_data = Slack::ReportService.new.send_report('month', 1.month.ago)
    Event.create(event_type: Event::EVENT_TYPES[:monthly_report], content: signup_data)
  end
end
