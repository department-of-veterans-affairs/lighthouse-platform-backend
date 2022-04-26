# frozen_string_literal: true

class SlackService
  def initialize
    @client = Slack::Web::Client.new
  end

  def alert_slack(channel, message)
    @client.chat_postMessage(channel: channel, text: message, as_user: true)
  end
end
