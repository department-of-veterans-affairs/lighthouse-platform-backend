# frozen_string_literal: true

require 'date'

module Kong
  class DriftService
    def initialize(environment = nil)
      @env = environment
      @client = production? ? Kong::ProductionService : Kong::SandboxService
      @slack_service = Slack::AlertService.new
    end

    def detect_drift
      consumers = @client.new.pull_kong_consumers
      consumers_last_day = filter_last_day(consumers)
      alert_on_list = detect_unknown_entities(consumers_last_day) unless consumers_last_day.empty?
      alert_on_list.map { |consumer| alert_slack consumer } if alert_on_list.present?

      { success: true }
    end

    private

    def alert_slack(consumer)
      message = build_message(consumer)
      @slack_service.send_message(Figaro.env.slack_drift_channel, { text: message })
    end

    def build_message(consumer)
      environment = production? ? 'Production' : 'Sandbox'
      [
        '*Lighthouse Consumer Management Service Notification*',
        "Detected an unknown Consumer within Kong Environment: #{environment}",
        "Client ID: <#{consumer[:client_id]}>"
      ].join("\n")
    end

    def detect_unknown_entities
      filter_last_day.filter do |id|
        new_record? id
      end
    end

    def filter_last_day
      pull_kong_consumers.filter do |consumer|
        consumer if consumer['created_at'] >= Date.yesterday.to_time.to_i
      end
    end

    def new_record?(consumer)
      consumer_id = consumer['id']
      ConsumerAuthRef.find_by(
        '(key=? or key=?) and value=?',
        ConsumerAuthRef::KEYS[:sandbox_gateway_ref],
        ConsumerAuthRef::KEYS[:prod_gateway_ref],
        consumer_id
      )
    end

    def production?
      @env.eql?(:production)
    end

    def pull_kong_consumers
      @client.new.list_all_consumers
    end
  end
end
