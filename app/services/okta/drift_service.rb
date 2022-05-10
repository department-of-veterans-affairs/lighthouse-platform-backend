# frozen_string_literal: true

module Okta
  class DriftService
    def initialize(environment = nil)
      @env = environment
      @client = production? ? Okta::ProductionService : Okta::SandboxService
      @slack_service = Slack::AlertService.new
    end

    def detect_drift
      applications = @client.new.list_applications
      apps_last_day = filter_last_day(applications)
      alert_on_list = detect_unknown_entities(apps_last_day) unless apps_last_day.empty?
      alert_on_list.map { |consumer| alert_slack consumer } if alert_on_list.present?

      { success: true }
    end

    private

    def filter_last_day(applications)
      applications.filter do |app|
        app[:created] >= 1.day.ago && !app[:label].end_with?('-dev')
      end
    end

    def detect_unknown_entities(alert_list)
      alert_list.filter { |app| new_record? app }
    end

    def alert_slack(consumer)
      message = build_message(consumer)
      @slack_service.send_message(Figaro.env.slack_drift_channel, { text: message })
    end

    def new_record?(application)
      credentials = application[:credentials]
      if credentials[:oauthClient].present? && credentials[:oauthClient][:client_id].present?
        cid = credentials[:oauthClient][:client_id]
        ConsumerAuthRef.find_by('(key=? or key=?) and value=?',
                                ConsumerAuthRef::KEYS[:sandbox_acg_oauth_ref],
                                ConsumerAuthRef::KEYS[:prod_acg_oauth_ref],
                                cid)&.consumer.blank?
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
        "Detected an unknown Consumer within Okta Environment: #{environment}",
        "Client ID: <#{url}|#{consumer[:credentials][:oauthClient][:client_id]}>"
      ].join("\n")
    end
  end
end
