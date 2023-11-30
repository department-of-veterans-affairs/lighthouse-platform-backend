# frozen_string_literal: true

module V0
  module Entities
    class ConsumerApplicationEntity < Grape::Entity
      expose :apis, documentation: { type: String } do |user, _options|
        user.consumer.apis_list.map(&:api_ref).map(&:name).join(',')
      end

      expose :clientID, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumers, :acg, :credentials, :oauthClient, :client_id)
      end

      expose :clientSecret, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumers, :acg, :credentials, :oauthClient, :client_secret)
      end

      expose :ccgClientId, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumers, :ccg, :credentials, :oauthClient, :client_id)
      end

      expose :email, documentation: { type: String }

      expose :kongUsername, documentation: { type: String } do |_user, options|
        options.dig(:kong_consumer, :kong_username)
      end

      expose :token, documentation: { type: String } do |_user, options|
        options.dig(:kong_consumer, :token)
      end

      expose :redirectURI, documentation: { type: String } do |_user, options|
        redirect_uris = options.dig(:okta_consumers, :acg, :settings, :oauthClient, :redirect_uris)
        redirect_uris.first if redirect_uris.present?
      end

      expose :userId, documentation: { type: Integer } do |user, _options|
        user[:id]
      end

      expose :deeplinkHash, documentation: { type: String } do |_user, options|
        options[:deeplink_hash] if Flipper.enabled? :deeplink_in_sandbox_callback
      end
    end
  end
end
