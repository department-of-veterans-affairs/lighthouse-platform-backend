# frozen_string_literal: true

module Okta
  class TokenValidationService
    def token_valid?(token)
      # this path is an exception in the VCR config to allow the cassette to be used
      uri = URI.parse("#{Figaro.env.prod_kong_elb}/internal/auth/v2/validation")
      req = Net::HTTP::Post.new(uri)

      request(req, uri, token)
    end

    private

    def request(req, uri, token)
      req['Authorization'] = "Bearer #{token}"
      req['apikey'] = Figaro.env.validate_token_apikey
      req.set_form_data({ aud: Figaro.env.okta_audience })

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.to_s.start_with?('https')) do |http|
        http.request(req)
      end

      response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }

      JSON.parse(response.body) unless response.body.nil?
    end
  end
end
