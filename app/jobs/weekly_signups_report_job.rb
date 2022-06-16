# frozen_string_literal: true

class WeeklySignupsReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    if Flipper.enabled?(:alert_signups_report)
      signup_data = Slack::ReportService.new.send_weekly_report
      Event.create(event_type: Event::EVENT_TYPES[:weekly_report], content: signup_data)
    end
  end
end
