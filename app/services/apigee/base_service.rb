# frozen_string_literal: true

require 'net/http'

module Apigee
  class BaseService
    attr_reader :client

    def initialize
      @client = Net::HTTP
      @apigee = apigee_gateway
    end

    def consumer_signup(user, kong_consumer, okta_consumers, apigee_route)
      uri = URI.parse("#{@apigee}/#{apigee_route}")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      data = request_data(user, kong_consumer, okta_consumers, apigee_route)
      req.body = data.to_json
      request(req, uri)
    end

    protected

    def apigee_gateway
      raise 'NotImplemented'
    end

    def apigee_gateway_apikey
      raise 'NotImplemented'
    end

    private

    def request_data(user, kong_consumer, okta_consumers, apigee_route)
      request = {
        developer: {
          email: user.email.downcase
        },
        keys: build_key_list(user.consumer, kong_consumer, okta_consumers)
      }

      request = append_consumer_data(request, user, kong_consumer, okta_consumers) if apigee_route == 'consumer'

      request
    end

    def append_consumer_data(request, user, kong_consumer, okta_consumers)
      request[:developer][:firstName] = user.first_name
      request[:developer][:lastName] = user.last_name
      request[:developer][:userName] = define_username(kong_consumer, okta_consumers)

      request
    end

    def define_username(kong_consumer, okta_consumers)
      kong_consumer&.[](:kong_username) || okta_consumers&.[](:acg)&.[](:label) || okta_consumers&.[](:ccg)&.[](:label)
    end

    def build_key_list(consumer, kong_consumer, okta_consumers)
      acg = okta_consumers[:acg]
      ccg = okta_consumers[:ccg]

      apis = consumer.apis_list

      [].tap do |a|
        a << kong_consumer_data(apis, kong_consumer[:token]) unless kong_consumer.nil?
        a << okta_consumer_data(apis, okta_consumers, 'acg') unless acg.nil?
        a << okta_consumer_data(apis, okta_consumers, 'ccg') unless ccg.nil?
      end
    end

    def kong_consumer_data(apis, token)
      {
        key: token,
        apiProducts: api_product_list(apis, 'apikey')
      }
    end

    def okta_consumer_data(apis, okta_consumers, type)
      consumer = { clientId: okta_consumers.dig(type.to_sym, :credentials, :oauthClient, :client_id) }
      if type == 'acg'
        consumer[:clientSecret] =
          okta_consumers.dig(:acg, :credentials, :oauthClient, :client_secret)
      end
      consumer[:apiProducts] = api_product_list(apis, type)
      consumer
    end

    def api_product_list(apis, type)
      [].tap do |a|
        apis.each { |api| a << api.name if api.auth_type == type }
      end
    end

    def request(req, uri)
      req['apikey'] = apigee_gateway_apikey
      response = @client.start(uri.host, uri.port, use_ssl: uri.to_s.start_with?('https'),
                                                   verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(req)
      end

      response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
      raise 'Failed to access apigee gateway' unless response['ok']

      JSON.parse(response.body) unless response.body.nil?
    end
  end
end
