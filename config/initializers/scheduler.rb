# frozen_string_literal: true

require 'rufus-scheduler'

s = Rufus::Scheduler.singleton

s.cron '0 2 * * *' do
  BackgroundJobEnforcer.create(job_type: Event::EVENT_TYPES[:drift_job], date: Time.zone.today)
  OktaDriftJob.perform_now
  KongDriftJob.perform_now
rescue ActiveRecord::RecordNotUnique
  # ignore, its already being handled
end

s.cron '0 11 * * 1' do
  BackgroundJobEnforcer.create(job_type: Event::EVENT_TYPES[:weekly_report], date: Time.zone.today)
  WeeklySignupsReportJob.perform_now
rescue ActiveRecord::RecordNotUnique
  # ignore, its already being handled
end

s.cron '0 11 1 * *' do
  BackgroundJobEnforcer.create(job_type: Event::EVENT_TYPES[:monthly_report], date: Time.zone.today)
  MonthlySignupsReportJob.perform_now
rescue ActiveRecord::RecordNotUnique
  # ignore, its already being handled
end
