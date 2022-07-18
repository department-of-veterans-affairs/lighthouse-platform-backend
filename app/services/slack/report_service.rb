# frozen_string_literal: true

module Slack
  class ReportService < AlertService
    def send_report(span, start_date)
      signup_data = query_events(span, start_date)
      message = report_message(span, signup_data)
      send_message(Figaro.env.slack_signup_channel, message)
      signup_data
    end

    def query_events(span, start_date)
      ActiveRecord::Base.connection.execute(build_query(span, start_date)).first
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

    def generate_query(start_date)
      sort_refs.map do |ref|
        "#{new_query(ref, start_date)} #{all_time_query(ref)}"
      end
    end

    def like_query(ref)
      "(content->>'apis' like '#{ref}' or content->>'apis' like '%,#{ref}' or content->>'apis' like '#{ref},%' or content->>'apis' like '%,#{ref},%')"
    end

    def new_query(ref, start_date)
      "COUNT(DISTINCT (case WHEN (created_at > '#{start_date}' AND content->'email' NOT IN (SELECT DISTINCT(content->'email') FROM events WHERE created_at < '#{start_date}' and event_type='sandbox_signup' AND #{like_query(ref)}) AND #{like_query(ref)}) then content->'email' end)) as \"#{ref_builder(ref)[:new]}\","
    end

    def all_time_query(ref)
      "COUNT(DISTINCT (case when #{like_query(ref)} then content->'email' end)) as \"#{ref_builder(ref)[:all]}\","
    end

    def build_query(span, start_date)
      "SELECT #{generate_query(start_date).join(' ')} COUNT(DISTINCT(case WHEN (created_at > '#{start_date}' AND content->'email' NOT IN (SELECT DISTINCT(content->'email') FROM events WHERE created_at < '#{start_date}' and event_type='sandbox_signup')) then content->'email' end)) as #{span}ly_count, COUNT(DISTINCT content->'email') as total_count FROM events WHERE event_type='sandbox_signup';"
    end

    def report_message(span, totals)
      extract_count = "#{span}ly_count"
      end_date = DateTime.now.strftime('%m/%d/%Y')
      message = {
        blocks: [
          {
            text: {
              text: "*#{span.capitalize}ly Sign-ups and Access Requests* for #{span.capitalize} Ending #{end_date}",
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
                text: "_This #{span}:_ #{totals[extract_count]} new users",
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
            new_signups = totals[ref_builder(api)[:new]]
            all_time = totals[ref_builder(api)[:all]]
            f << {
              text: "_#{api}_: #{new_signups} new requests (#{all_time} all-time)",
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
