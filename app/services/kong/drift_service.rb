# frozen_string_literal: true

require 'date'

module Kong
  class DriftService
    def initialize(environment = nil)
      @env = environment
      @client = Kong::SandboxService
    end

    def pull_kong_consumers
      @client.new.list_all_consumers
    end

    def time_sort
      pull_kong_consumers.filter do |consumer|
        consumer if consumer['created_at'] >= Date.yesterday.to_time.to_i
      end
    end

    def detect_unknown_entities(alert_list)
      alert_list.filter do |cid|
        new_record? cid
      end
    end

    def alert_slack(consumer)
      @slack_service ||= SlackService.new
      message = build_message(consumer)
      @slack_service.alert_slack(Figaro.env.slack_drift_channel, message)
    end

    def new_record?(consumer)
      cid = consumer['created_at']
      if cid.present?
        Consumer.find_by(production? ? { user_id: cid } : { user_id: cid }).nil?
      end
    end

    def production?
      @env.eql?(:production)
    end

    def trim_url(url)
      url[0...-5]
    end

    def build_message(consumer)
      url = trim_url(consumer[:_links][:uploadLogo][:href]) if consumer[:_links].present?
      environment = production? ? 'Production' : 'Sandbox'
      [
        '*Lighthouse Consumer Management Service Notification*',
        "Detected an unknown Consumer within Kong Environment: #{environment}",
        "Client ID: <#{url}|#{consumer[:credentials][:oauthClient][:client_id]}>"
      ].join("\n")
    end
  end
end
