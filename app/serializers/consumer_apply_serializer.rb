# frozen_string_literal: true

class ConsumerApplySerializer < Blueprinter::Base
  field :apis do |user, _options|
    user.consumer.apis_list
  end

  field :clientId do |_user, options|
    if options[:okta].blank?
      nil
    else
      options[:okta].credentials.oauthClient.client_id
    end
  end

  field :clientSecret do |_user, options|
    if options[:okta].blank?
      nil
    else
      options[:okta].credentials.oauthClient.client_secret
    end
  end

  field :email

  field :kongUsername do |_user, options|
    options.dig(:kong, :kongUsername)
  end

  field :token do |_user, options|
    options.dig(:kong, :token)
  end

  field :redirectURI do |_user, options|
    if options[:okta].blank?
      nil
    else
      options[:okta].settings.oauthClient.redirect_uris.first
    end
  end
end
