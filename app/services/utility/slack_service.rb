module Utility
    class SlackService
        def alert_slack(consumer, service)
            @slack_service ||= SlackService.new
            message = build_message(consumer, service)
            @slack_service.alert_slack(Figaro.env.slack_drift_channel, message)
        end

        def build_message(consumer, service)
            url = trim_url(consumer[:_links][:uploadLogo][:href]) if consumer[:_links].present?
            environment = production? ? 'Production' : 'Sandbox'
            [
              '*Lighthouse Consumer Management Service Notification*',
              "Detected an unknown Consumer within #{service} Environment: #{environment}"
            ].join("\n")
          end
    end
end