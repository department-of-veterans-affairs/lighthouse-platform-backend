# frozen_string_literal: true

module Slack
  class AlertService
    def initialize
      @client = Slack::Web::Client.new
    end

    def alert_slack(channel, message)
      @key = message.keys.first
      @client.chat_postMessage(channel: channel, @key => message[@key], as_user: true) if valid_key?
    end

    def valid_key?
      if @key == :attachments || @key == :blocks || @key == :text
        return true
      end
      raise 'Invalid Slack Key'
    end
  end
end
