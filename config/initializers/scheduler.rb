# frozen_string_literal: true

require 'rufus-scheduler'

s = Rufus::Scheduler.singleton

s.cron '0 2 * * *' do
  OktaDriftJob.perform_now
  KongDriftJob.perform_now
end

s.cron '0 7 * * 1' do
  WeeklySignupsReportJob.perform_now
end
