# frozen_string_literal: true

class SlackService
  def initialize
    @client = Slack::Web::Client.new
  end

  def alert_slack(channel, message)
    @client.chat_postMessage(channel: channel, attachments: message[:attachments], as_user: true) if use_attachments? message
    @client.chat_postMessage(channel: channel, text: message, as_user: true) unless use_attachments? message
  end

  def use_attachments?(message)
    message[:attachments].present?
  end
end
