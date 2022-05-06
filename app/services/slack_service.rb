# frozen_string_literal: true

class SlackService
  def initialize
    @client = Slack::Web::Client.new
  end

  def alert_slack(channel, message)
    if use_string? message
      @client.chat_postMessage(channel: channel, text: message, as_user: true)
    else
      @client.chat_postMessage(channel: channel, attachments: message[:attachments],
                               as_user: true)
    end
  end

  def use_string?(message)
    message.instance_of?(String)
  end
end
