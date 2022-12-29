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

    def list_all_applications
      resp, = @client.list_applications(query: { limit: 200 }, paginate: true)
      resp.map(&:to_h)
    end

    def consumer_signup(user, options = {})
      acg_application = consumer_signup_per_type(user, 'acg', options)
      ccg_application = consumer_signup_per_type(user, 'ccg', options)

      { acg: acg_application, ccg: ccg_application }
    end

    def internal_consumer_signup(user, type, api, options)
      application = create_application(user, type, options)

      client_id = application.credentials.oauthClient.client_id
      append_default_policy(client_id, type, api)

      save_id_to_user(user, type, application.to_h[:id])

      { type.to_sym => application.to_h }
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

    def environment_key
      raise 'NotImplemented'
    end

    private

    def consumer_signup_per_type(user, type, options = {})
      oauth_apis = user.consumer.apis_list.select { |api| api.auth_type == type }
      return if oauth_apis.blank?

      application = create_application(user, type, options)

      client_id = application.credentials.oauthClient.client_id
      oauth_apis.each { |api| append_default_policy(client_id, type, api) }

      save_id_to_user(user, type, application.to_h[:id])

      application.to_h
    end

    def create_application(user, type, options)
      new_application_request = build_new_application_payload(user, type, options)
      application, status_code = @client.add_application(new_application_request)

      raise handle_okta_error(application) unless status_code == 200

      assign_response, status_code = @client.assign_group_to_application(application.id, idme_group)
      raise assign_response[:errorSummary] unless status_code == 200

      application
    end

    def append_default_policy(client_id, type, api)
      auth_server_id = auth_server_id(api, type)
      policies, status_code = @client.list_authorization_server_policies(auth_server_id)

      raise handle_okta_error(policies) unless status_code == 200

      default_policy = policies.detect { |policy| policy.name == Figaro.env.okta_default_policy }
      default_policy = policies.detect { |policy| policy.name == '*/* (all scopes)' } if default_policy.blank?
      raise "No default policy for clientId: #{client_id}, authServerId: #{auth_server_id}" if default_policy.blank?

      default_policy.conditions.clients.include.push(client_id)
      @client.update_authorization_server_policy(auth_server_id, default_policy.id, default_policy.to_h)
      raise "Okta failed to add clientId: #{client_id} to policy: #{default_policy.id}" unless status_code == 200
    end

    def save_id_to_user(user, type, id)
      auth_ref_key = ConsumerAuthRef::KEYS["#{environment_key}_#{type}_oauth_ref".to_sym]
      existing_auth_ref = user.consumer.consumer_auth_refs.kept.find_by(key: auth_ref_key)
      existing_auth_ref.discard if existing_auth_ref.present?
      auth_ref = ConsumerAuthRef.new(consumer: user.consumer, key: auth_ref_key, value: id)
      user.consumer.consumer_auth_refs.push(auth_ref)
      user.save!
      user.undiscard if user.discarded?
    end

    def auth_server_id(api, type)
      server_per_type = api.api_metadatum.oauth_info.acgInfo.sandboxAud | api.api_metadatum.oauth_info.ccgInfo.sandboxAud
      return server_per_type if server_per_type.present?
    end

    def consumer_name(user)
      "#{user.consumer.organization}#{user.last_name}".gsub(/\W/, '')
    end

    def lower_env?
      Flipper.enabled? :denote_lower_environment
    end

    def construct_label(user)
      "#{consumer_name(user)}-#{Time.now.to_i}#{lower_env? ? '-dev' : ''}"
    end

    def build_new_application_payload(user, type, options = {})
      return build_new_ccg_application_payload(user, options) if type == 'ccg'
      return build_new_acg_application_payload(user, options) if type == 'acg'

      raise 'Invalid supplied arguments'
    end

    def handle_okta_error(application)
      app = application.to_h
      summary = app[:errorSummary]
      cause = app[:errorCauses]&.first&.dig(:errorSummary)
      response_cause = " - #{cause}" if cause.present?
      summary + (response_cause || '')
    end

    def build_new_acg_application_payload(user, options)
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
            application_type: options[:application_type],
            consent_method: 'REQUIRED',
            grant_types: %w[authorization_code refresh_token],
            initiate_login_uri: login_url,
            redirect_uris: [options[:redirect_uri], va_redirect],
            response_types: ['code']
          }
        }
      }
    end

    def build_new_ccg_application_payload(user, options)
      {
        name: 'oidc_client',
        label: construct_label(user),
        signOnMode: 'OPENID_CONNECT',
        credentials: {
          oauthClient: {
            autoKeyRotation: true,
            token_endpoint_auth_method: 'private_key_jwt'
          }
        },
        settings: {
          oauthClient: {
            application_type: 'service',
            grant_types: %w[client_credentials],
            response_types: %w[token],
            jwks: {
              keys: [
                options[:application_public_key].symbolize_keys
              ]
            }
          }
        }
      }
    end
  end
end
