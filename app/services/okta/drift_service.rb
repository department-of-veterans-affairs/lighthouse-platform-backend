# frozen_string_literal: true

module Okta
  class DriftService
    def initialize(environment = nil)
      @env = environment
      @client = is_production? ? Okta::ProductionService : Okta::SandboxService
    end

    def detect_drift
      applications = @client.new.list_applications
      apps_last_day = filter_last_day(applications)
      alert_on_list = detect_unknown_entities(apps_last_day) unless apps_last_day.empty?
      if alert_on_list.present?
        @slack_service = SlackService.new
        alert_on_list.map do |consumer|
          alert_slack consumer
        end
      end
    end

    private

    def filter_last_day(applications)
      applications.filter do |app|
        app[:created] >= 1.day.ago
      end
    end

    def detect_unknown_entities(alert_list)
      alert_list.filter do |app|
        is_new_record? app
      end
    end

    def alert_slack(consumer)
      message = "Consumer: #{consumer[:credentials][:oauthClient][:client_id]}"
      @slack_service.alert_slack(Figaro.env.drift_webhook, message)
    end

    def is_new_record?(application)
      Consumer.find_by(sandbox_oauth_ref: application[:credentials][:oauthClient][:client_id]).nil?
    end

    def is_production?
      @env.eql?(:production)
    end
  end
end
