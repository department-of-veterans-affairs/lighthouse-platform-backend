# frozen_string_literal: true

require 'net/http'

module Utility
  class SeedService
    attr_reader :client

    def initialize
      @client = Net::HTTP
      @kong_elb = Figaro.env.kong_elb || 'http://localhost:4001'
      @es_base = Figaro.env.es_endpoint || 'http://localhost:9200'
      @dynamo = Aws::DynamoDB::Client.new(dynamo_client_options)
    end

    def seed_services
      seed_kong
      seed_elasticsearch
      seed_dynamo
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

    # dynamo seeds
    def seed_dynamo
      initialize_dynamo_db
      seed_dynamo_db(2)
    end

    def initialize_dynamo_db # rubocop:disable Metrics/MethodLength
      raise 'just development environment things' if Figaro.env.dynamo_endpoint.blank?

      @dynamo.create_table(
        {
          attribute_definitions: [
            { attribute_name: 'createdAt', attribute_type: 'S' },
            { attribute_name: 'email', attribute_type: 'S' }
          ],
          key_schema: [
            { attribute_name: 'email', key_type: 'HASH' },
            { attribute_name: 'createdAt', key_type: 'RANGE' }
          ],
          provisioned_throughput: {
            read_capacity_units: 10,
            write_capacity_units: 10
          },
          table_name: Figaro.env.dynamo_table_name
        }
      )

      Rails.logger.info "#{Figaro.env.dynamo_table_name} table created."
    end

    def seed_dynamo_db(num_dynamo_users = 100) # rubocop:disable Metrics/MethodLength
      raise 'just development environment things' if Figaro.env.dynamo_endpoint.blank?

      num_dynamo_users.times do
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name
        @dynamo.put_item(
          {
            item: {
              apis: ['benefits', 'facilities', 'benefits,facilities'].sample,
              organization: 'none',
              firstName: first_name,
              lastName: last_name,
              createdAt: Time.zone.now.to_s,
              description: ['no description', Faker::Lorem.paragraph].sample,
              email: "#{first_name}.#{last_name}@va.gov",
              tosAccepted: [true, false].sample,
              kongConsumerId: %w[b11ae7d9-2949-4e80-aa55-ccd30d4c7287 6b6f692b-0ec1-4224-9016-f7c65de680f9].sample
            },
            table_name: Figaro.env.dynamo_table_name
          }
        )
      end

      Rails.logger.info "#{num_dynamo_users} users created in dynamo #{Figaro.env.dynamo_table_name} table."
    end

    #
    # Note: "endpoint" option is only required running dynamodb locally in a development environment
    #
    # @return [Hash] Options to initialize a dynamo db client
    def dynamo_client_options
      credentials = Aws::Credentials.new(Figaro.env.dynamo_access_key_id, Figaro.env.dynamo_secret_access_key)
      options = {
        region: Figaro.env.aws_region,
        credentials: credentials
      }
      options[:endpoint] = Figaro.env.dynamo_endpoint if Figaro.env.dynamo_endpoint.present?

      options
    end
  end
end
