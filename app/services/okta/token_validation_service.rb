# frozen_string_literal: true

module Okta
  class TokenValidationService
    KEYS = {
      alg: 'RS256'
    }.freeze

    def token_valid?(token)
      auth_server_id = Figaro.env.okta_auth_server

      uri = URI.parse("#{Figaro.env.okta_token_validation_endpoint}/oauth2/#{auth_server_id}/v1/introspect")
      req = Net::HTTP::Post.new(uri)

      request(req, uri, token)
    end

    private

    def request(req, uri, token)
      client_id = Figaro.env.okta_client_id
      client_secret = Figaro.env.okta_client_secret
      req.basic_auth(client_id, client_secret)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.to_s.start_with?('https')) do |http|
        post_data = URI.encode_www_form({ token: token, token_type_hint: 'access_token' })
        http.request(req, post_data)
      end

      response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
      Rails.logger.warn("??? #{response}") && raise('Failed to validate token with Okta') unless response['ok']

      JSON.parse(response.body) unless response.body.nil?
    end
  end
end
