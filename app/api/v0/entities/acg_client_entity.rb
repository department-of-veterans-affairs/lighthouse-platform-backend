# frozen_string_literal: true

module V0
  module Entities
    class AcgClientEntity < ProviderNameEntity
      expose :clientId, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumer, :acg, :credentials, :oauthClient, :client_id)
      end

      expose :clientSecret, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumer, :acg, :credentials, :oauthClient, :client_secret)
      end

      expose :oAuthApplicationType, documentation: { type: String } do |_user, options|
        options.dig(:params, :oAuthApplicationType)
      end

      expose :oAuthRedirectUri, documentation: { type: String } do |_user, options|
        options.dig(:params, :oAuthRedirectUri)
      end
    end
  end
end
