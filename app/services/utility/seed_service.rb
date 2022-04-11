# frozen_string_literal: true

require 'net/http'

module Utility
  class SeedService
    attr_reader :client

    def initialize
      @client = Net::HTTP
      @kong_elb = Figaro.env.kong_elb
    end

    # seeds local Kong gateway for testing purposes
    def seed_kong
      plugin_add_key_auth
      plugin_add_acl
      seed_kong_consumers
    end

    def construct_consumer_list
      %w[lighthouse-consumer kong-consumer]
    end

    def plugin_add_key_auth
      uri = URI.parse("#{@kong_elb}/plugins")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { name: 'key-auth', config: { key_names: ['apikey'] } }.to_json
      request(req, uri)
    end

    def plugin_add_acl
      uri = URI.parse("#{@kong_elb}/plugins")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { name: 'acl', config: { allow: ['local_access'] } }.to_json
      request(req, uri)
    end

    def seed_kong_consumers
      construct_consumer_list.map do |consumer|
        uri = URI.parse("#{@kong_elb}/consumers")
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req.body = { username: consumer }.to_json
        request(req, uri)
      end
    end
    # end Kong seeds

    def request(req, uri)
      req.basic_auth 'kong_admin', nil
      response = @client.start(uri.host, uri.port) do |http|
        http.request(req)
      end

      response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
      raise 'Failed to retrieve kong consumers list' unless response['ok']

      JSON.parse(response.body) unless response.body.nil?
    end
  end
end
