# frozen_string_literal: true

require 'oktakit'

module Okta
  class BaseService
    def initialize
      @client = Oktakit::Client.new(token: okta_token, api_endpoint: okta_api_endpoint)
    end

    def list_applications
      resp, = @client.list_applications
      resp.map(&:to_h)
    end

    def consumer_signup(user, oauth, application_type:, redirect_uri:)
      raise 'Missing oauth APIs' if oauth.empty?

      new_application_request = build_new_application_payload(user,
                                                              application_type: application_type,
                                                              redirect_uri: redirect_uri)
      application, status_code = @client.add_application(new_application_request)
      raise application[:errorSummary] unless status_code == 200

      assign_response, status_code = @client.assign_group_to_application(application.id, idme_group)
      raise assign_response[:errorSummary] unless status_code == 200

      client_id = application.credentials.oauthClient.client_id
      oauth.each do |auth_server_access_key|
        auth_server_id = Figaro.env.send(auth_server_access_key)
        policies, status_code = @client.list_authorization_server_policies(auth_server_id)
        raise policies[:errorSummary] unless status_code == 200

        default_policy = policies.detect { |policy| policy.name == Figaro.env.okta_default_policy }
        raise "No default policy for clientId: #{client_id}, authServerId: #{auth_server_id}" if default_policy.blank?

        default_policy.conditions.clients.include.push(client_id)
        @client.update_authorization_server_policy(auth_server_id, default_policy.id, default_policy)
      end

      application
    end

    private

    def consumer_name(user)
      "LPB-#{"#{user.consumer.organization}#{user.last_name}".gsub(/\W/, '')}"
    end

    def lower_env?
      Flipper.enabled? :denote_lower_environment
    end

    def construct_label(user)
      "#{consumer_name(user)}-#{Time.now.to_i}#{lower_env? ? '-dev' : ''}"
    end

    def build_new_application_payload(user, application_type:, redirect_uri:)
      {
        name: 'oidc_client',
        label: construct_label(user),
        signOnMode: 'OPENID_CONNECT',
        credentials: {
          oauthClient: {
            autoKeyRotation: true,
            token_endpoint_auth_method: 'client_secret_basic'
          }
        },
        visibility: {
          autoSubmitToolbar: false,
          hide: {
            iOS: true,
            web: true
          },
          appLinks: {
            login: false
          }
        },
        settings: {
          oauthClient: {
            application_type: application_type,
            consent_method: 'REQUIRED',
            grant_types: %w[authorization_code refresh_token],
            initiate_login_uri: login_url,
            redirect_uris: [redirect_uri, va_redirect],
            response_types: ['code']
          }
        }
      }
    end

    protected

    def idme_group
      raise 'NotImplemented'
    end

    def login_url
      Figaro.env.okta_login_url
    end

    def okta_api_endpoint
      raise 'NotImplemented'
    end

    def okta_token
      raise 'NotImplemented'
    end

    def va_redirect
      raise 'NotImplemented'
    end
  end
end
