module V0
  module Entities
    class ConsumerApplicationEntity < Grape::Entity
      expose :apis, documentation: { type: String } do |user, _options|
        user.consumer.apis_list
      end

      expose :clientId, documentation: { type: String } do |_user, options|
        options[:okta].credentials.oauthClient.client_id if options[:okta].present?
      end

      expose :clientSecret, documentation: { type: String } do |_user, options|
        options[:okta].credentials.oauthClient.client_secret if options[:okta].present?
      end

      expose :email, documentation: { type: String }

      expose :kongUsername, documentation: { type: String } do |_user, options|
        options.dig(:kong, :kongUsername)
      end

      expose :token, documentation: { type: String } do |_user, options|
        options.dig(:kong, :token)
      end

      expose :redirectURI, documentation: { type: String } do |_user, options|
        options[:okta].settings.oauthClient.redirect_uris.first if options[:okta].present?
      end
    end
  end
end
