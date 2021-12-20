# frozen_string_literal: true

class ConsumerApplySerializer < Blueprinter::Base
  field :apis do |user, _options|
    user.consumer.apis_list
  end

  field :clientId do |_user, options|
    options[:okta].credentials.oauthClient.client_id if options[:okta].present?
  end

  field :clientSecret do |_user, options|
    options[:okta].credentials.oauthClient.client_secret if options[:okta].present?
  end

  field :email

  field :kongUsername do |_user, options|
    options.dig(:kong, :kongUsername)
  end

  field :token do |_user, options|
    options.dig(:kong, :token)
  end

  field :redirectURI do |_user, options|
    options[:okta].settings.oauthClient.redirect_uris.first if options[:okta].present?
  end
end
