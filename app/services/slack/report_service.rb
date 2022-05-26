# frozen_string_literal: true

module Slack
  class ReportService < AlertService
    def send_weekly_report
      message = weekly_report_message('week', query_events)
      send_message(Figaro.env.slack_signup_channel, message)
    end

    private

    def ref_builder(ref)
      {
        all: "#{ref.downcase}_all_count",
        new: "#{ref.downcase}_new_count"
      }
    end

    def sort_refs
      ApiRef.all.map(&:name).uniq.sort
    end

    def generate_query
      sort_refs.map do |ref|
        "#{new_query(ref)} #{all_time_query(ref)}"
      end
    end

    def like_query(ref)
      "(content->>'apis' like '#{ref}' or content->>'apis' like '%,#{ref}' or content->>'apis' like '#{ref},%' or content->>'apis' like '%,#{ref},%')"
    end

    def new_query(ref)
      "SUM((case WHEN (created_at > '#{1.week.ago}' AND content->'email' NOT IN (SELECT DISTINCT(content->'email') FROM events WHERE created_at < '#{1.week.ago}') AND #{like_query(ref)}) then 1 else 0 end)) as \"#{ref_builder(ref)[:new]}\","
    end

    def all_time_query(ref)
      "COUNT(DISTINCT (case when created_at < '#{1.week.ago}' AND #{like_query(ref)} then content->'email' end)) as \"#{ref_builder(ref)[:all]}\","
    end

    def build_query
      "SELECT #{generate_query.join(' ')} SUM(case WHEN (created_at > '#{1.week.ago}' AND content->'email' NOT IN (SELECT DISTINCT(content->'email') FROM events WHERE created_at < '#{1.week.ago}')) then 1 else 0 end) as weekly_count, COUNT(DISTINCT content->'email') as total_count FROM events WHERE event_type='sandbox_signup';"
    end

    def query_events
      ActiveRecord::Base.connection.execute(build_query).first
    end

    def weekly_report_message(duration, totals)
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
                text: "_This week:_ #{totals['weekly_count']} new users",
                type: 'mrkdwn'
              },
              {
                text: "_All-time:_ #{totals['total_count']} new users",
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
      refs = sort_refs
      while refs.length.positive?
        # fields cannot be longer than 10 or slack returns an error
        ten_at_a_time = refs.slice(0, 10)
        fields = [].tap do |f|
          ten_at_a_time.map do |api|
            weekly = totals[ref_builder(api)[:new]]
            all_time = totals[ref_builder(api)[:all]]
            f << {
              text: "_#{api}_: #{weekly} new requests (#{all_time} all-time)",
              type: 'mrkdwn'
            }
          end
        end
        message[:blocks] << { type: 'section', fields: fields }
        refs.slice!(0, 10)
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
