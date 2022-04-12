# frozen_string_literal: true

require 'net/http'

module Utility
  class SeedService
    attr_reader :client

    def initialize
      @client = Net::HTTP
      @kong_elb = Figaro.env.kong_elb || 'http://localhost:4001'
      @es_base = Figaro.env.es_endpoint || 'http://localhost:9200'
    end

    def seed_services
      seed_kong
      seed_elasticsearch
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
      request(req, uri, :kong)
    end

    def plugin_add_acl
      uri = URI.parse("#{@kong_elb}/plugins")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { name: 'acl', config: { allow: ['local_access'] } }.to_json
      request(req, uri, :kong)
    end

    def seed_kong_consumers
      construct_consumer_list.map do |consumer|
        uri = URI.parse("#{@kong_elb}/consumers")
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req.body = { username: consumer }.to_json
        request(req, uri, :kong)
      end
    end
    # end Kong seeds

    def seed_elasticsearch
      uri = URI.parse("#{@es_base}/_bulk")
      req = Net::HTTP::Post.new(uri)
      req.body = File.read(File.join(File.dirname(__FILE__), '../../../spec/support/elasticsearch/mock_logs.json'))
      request(req, uri, :elasticsearch)
    end

    def request(req, uri, service)
      req.basic_auth 'kong_admin', nil if service.eql?(:kong)
      if service.eql?(:elasticsearch)
        req['kbn-xsrf'] = true
        req['Content-type'] = 'application/json'
      end
      @client.start(uri.host, uri.port) do |http|
        http.request(req)
      end
    end
  end
end
