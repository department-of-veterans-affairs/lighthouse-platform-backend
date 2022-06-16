# frozen_string_literal: true

require 'rufus-scheduler'

s = Rufus::Scheduler.singleton

s.cron '0 2 * * *' do
  OktaDriftJob.perform_now
  KongDriftJob.perform_now
end

s.cron '0 11 * * 1' do
  BackgroundJobEnforcer.create(job_type: 'weekly_signups_report', date: Time.zone.today)
  WeeklySignupsReportJob.perform_now
rescue ActiveRecord::RecordNotUnique
  # ignore, its already being handled
end
