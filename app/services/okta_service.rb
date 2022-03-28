# frozen_string_literal: true

require 'oktakit'

class OktaService
  def initialize(env = nil)
    @env = env
    set_token
    set_endpoint
    @client = Oktakit::Client.new(token: @token, api_endpoint: @api_endpoint)
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

    assign_response, status_code = @client.assign_group_to_application(application.id, declare_idme_group)
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

  def declare_va_redirect
    if @env.nil?
      Figaro.env.okta_redirect_url
    else
      Figaro.env.prod_okta_redirect_url
    end
  end

  def declare_idme_group
    if @env.nil?
      Figaro.env.idme_group_id
    else
      Figaro.env.prod_idme_group_id
    end
  end

  def set_token
    @token = if @env.nil?
               Figaro.env.okta_token
             else
               Figaro.env.prod_okta_token
             end
  end

  def set_endpoint
    @api_endpoint = if @env.nil?
                      Figaro.env.okta_api_endpoint
                    else
                      Figaro.env.prod_okta_api_endpoint
                    end
  end

  def set_login_url
    @api_endpoint = if @env.nil?
                      Figaro.env.okta_login_url
                    else
                      Figaro.env.prod_okta_login_url
                    end
  end

  def build_new_application_payload(user, application_type:, redirect_uri:)
    {
      name: 'oidc_client',
      label: "#{consumer_name(user)}-#{Time.now.to_i}",
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
          initiate_login_uri: set_login_url,
          redirect_uris: [redirect_uri, declare_va_redirect],
          response_types: ['code']
        }
      }
    }
  end
end
