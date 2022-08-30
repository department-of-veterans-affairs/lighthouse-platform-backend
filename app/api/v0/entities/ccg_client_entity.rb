# frozen_string_literal: true

module V0
  module Entities
    class CcgClientEntity < ProviderNameEntity
      expose :clientId, documentation: { type: String } do |_user, options|
        options.dig(:okta_consumer, :ccg, :credentials, :oauthClient, :client_id)
      end

      expose :oAuthPublicKey, documentation: { type: String } do |_user, options|
        options.dig(:params, :oAuthPublicKey)
      end
    end
  end
end
