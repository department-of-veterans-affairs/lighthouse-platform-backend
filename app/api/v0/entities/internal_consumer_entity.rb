# frozen_string_literal: true

module V0
  module Entities
    class InternalConsumerEntity < Grape::Entity
      expose :apiName, documentation: { type: String } do |_user, options|
        options[:api_name]
      end

      expose :apiKey, documentation: { type: String } do |_user, options|
        options.dig(:kong_consumer, :token)
      end

      expose :acgClientID, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumer, :acg, :credentials, :oauthClient, :client_id)
      end

      expose :acgClientSecret, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumer, :acg, :credentials, :oauthClient, :client_secret)
      end

      expose :ccgClientId, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumer, :ccg, :credentials, :oauthClient, :client_id)
      end
    end
  end
end
