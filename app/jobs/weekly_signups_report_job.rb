# frozen_string_literal: true

class WeeklySignupsReport < ApplicationJob
  queue_as :default

  def perform(*_args)
    Slack::ReportService.new.send_weekly_report
  end
end
