# frozen_string_literal: true

module Slack
  class AlertService
    def initialize
      @client = Slack::Web::Client.new
    end

    def alert_slack(channel, message)
      @key = message.keys.first
      @client.chat_postMessage(channel: channel, @key => message[@key], as_user: true) if has_valid_key?(message)
    end

    def has_valid_key?(message)
      @key == :attachments || @key == :blocks || @key == :text
    end
  end
end
