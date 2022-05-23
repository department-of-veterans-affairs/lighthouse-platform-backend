# frozen_string_literal: true

module Slack
  class ReportService < AlertService
    def send_weekly_report
      time_span_signups, all_time_signups = calculate_signups
      totals = calculate_new_and_all_time
      message = weekly_report_message('week', time_span_signups, all_time_signups, totals)
      alert_slack(Figaro.env.slack_signup_channel, message)
    end

    private

    def calculate_signups
      last_weeks_emails = Event.timeframe(1.week.ago..).pluck('content').pluck('email').uniq
      all_time_emails = Event.timeframe(..1.week.ago).pluck('content').pluck('email').uniq
      time_span_signups = last_weeks_emails.filter do |email|
        all_time_emails.exclude?(email)
      end
      total_signups = all_time_emails.concat(time_span_signups).count

      [time_span_signups.count, total_signups]
    end

    def calculate_new_and_all_time
      current_week_count = Event.timeframe(1.week.ago..)
      all_time_count = Event.timeframe(..1.week.ago)
      calculations = build_calculation_array

      all_time_count.map do |event|
        handle_event_filter(event, calculations) if apis?(event)
      end

      current_week_count.map do |event|
        handle_event_filter(event, calculations, true) if apis?(event)
      end

      calculations
    end

    def apis?(event)
      event['content']['apis'].present?
    end

    def handle_event_filter(event, calculations, is_current = nil)
      event['content']['apis'].split(',').map do |api_ref|
        calc_object = calculations.find { |api| api[:key] == api_ref }
        manage_calculations(event, calc_object, is_current) if calc_object
      end
    end

    def manage_calculations(event, calc_object, is_current)
      email = event['content']['email']
      if is_current && (calc_object[:new_signups].exclude?(email) && calc_object[:all_time_signups].exclude?(email))
        calc_object[:new_signups] << email
      end
      calc_object[:all_time_signups] << email if calc_object[:all_time_signups].exclude?(email)
    end

    def build_calculation_array
      [].tap do |a|
        ApiRef.order(:name).map(&:name).uniq.map { |ref| a << { key: ref.to_s, new_signups: [], all_time_signups: [] } }
      end
    end

    def weekly_report_message(duration, time_span_signups, all_time_signups, totals)
      end_date = DateTime.now.strftime('%m/%d/%Y')
      message = {
        blocks: [
          {
            text: {
              text: "*#{duration.capitalize}ly Sign-ups and Access Requests* for #{duration.capitalize} Ending #{end_date}",
              type: 'mrkdwn'
            },
            type: 'section'
          },
          {
            text: {
              text: "*Environment:* #{Figaro.env.dsva_environment}",
              type: 'mrkdwn'
            },
            type: 'section'
          },
          {
            type: 'divider'
          },
          {
            text: {
              text: '*New User Sign-ups* (excludes established users requesting additional APIs)',
              type: 'mrkdwn'
            },
            type: 'section'
          },
          {
            fields: [
              {
                text: "_This week:_ #{time_span_signups} new users",
                type: 'mrkdwn'
              },
              {
                text: "_All-time:_ #{all_time_signups} new users",
                type: 'mrkdwn'
              }
            ],
            type: 'section'
          },
          {
            type: 'divider'
          },
          {
            text: {
              text: '*API Access Requests* (includes new users, and established users requesting additional APIs)',
              type: 'mrkdwn'
            },
            type: 'section'
          }
        ]
      }

      while totals.length.positive?
        # fields cannot be longer than 10 or slack returns an error
        ten_at_a_time = totals.slice(0, 10)
        fields = [].tap do |f|
          ten_at_a_time.map do |api|
            f << {
              text: "_#{api[:key]}_: #{api[:new_signups].count} new requests (#{api[:all_time_signups].count} all-time)",
              type: 'mrkdwn'
            }
          end
        end
        message[:blocks] << { type: 'section', fields: fields }
        totals.slice!(0, 10)
      end
      message[:blocks] << { type: 'divider' }
      message[:blocks] << {
        text: {
          text: '_Have questions about these numbers? Read <https://community.max.gov/display/VAExternal/Calculating Sandbox Signups|how we calculate signups>._',
          type: 'mrkdwn'
        },
        type: 'section'
      }
      message
    end
  end
end
