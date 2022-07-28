# frozen_string_literal: true

require 'net/http'
require 'socksify/http'

module Kong
  class BaseService
    attr_reader :client

    def initialize
      @client = Figaro.env.socks_host.present? ? Net::HTTP.SOCKSProxy(Figaro.env.socks_host, 2001) : Net::HTTP
      @kong_elb = kong_elb
    end

    def create_consumer(consumer_name)
      uri = URI.parse("#{@kong_elb}/consumers")
      req = Net::HTTP::Post.new(uri)
      req.set_form_data({ username: consumer_name })
      request(req, uri)
    end

    def list_consumers(query = nil)
      uri = URI.parse("#{@kong_elb}/consumers#{query}")
      req = Net::HTTP::Get.new(uri)
      request(req, uri)
    end

    def list_all_consumers
      offset = nil
      kong_consumers = []
      loop do
        query = offset.nil? ? '' : "?offset=#{offset}"
        res = list_consumers(query)
        kong_consumers.concat(res['data'])
        offset = res['offset']
        break if offset.nil?
      end
      kong_consumers
    end

    def get_consumer(id)
      uri = URI.parse("#{@kong_elb}/consumers/#{id}")
      req = Net::HTTP::Get.new(uri)
      request(req, uri)
    end

    def get_plugins(id)
      uri = URI.parse("#{@kong_elb}/consumers/#{id}/plugins")
      req = Net::HTTP::Get.new(uri)
      request(req, uri)
    end

    def add_acl(consumer, group)
      uri = URI.parse("#{@kong_elb}/consumers/#{consumer}/acls")
      req = Net::HTTP::Post.new(uri)
      req.set_form_data({ group: group })
      request(req, uri)
    end

    def get_acls(consumer)
      uri = URI.parse("#{@kong_elb}/consumers/#{consumer}/acls")
      req = Net::HTTP::Get.new(uri)
      request(req, uri)
    end

    def get_all_acls
      uri = URI.parse("#{@kong_elb}/acls")
      req = Net::HTTP::Get.new(uri)
      request(req, uri)
    end

    def get_all_keys
      uri = URI.parse("#{@kong_elb}/key-auths")
      req = Net::HTTP::Get.new(uri)
      request(req, uri)
    end

    def create_key(consumer)
      uri = URI.parse("#{@kong_elb}/consumers/#{consumer}/key-auth")
      req = Net::HTTP::Post.new(uri)
      request(req, uri)
    end

    def consumer_signup(user)
      key_auth_apis = user.consumer.apis_list.select { |api| api.auth_type == 'apikey' }
      return if key_auth_apis.blank?

      kong_id, kong_consumer_name, kong_api_key = handle_key_auth_flow(user.consumer.organization,
                                                                       user.last_name,
                                                                       key_auth_apis.map(&:acl))

      save_id_to_user(user, kong_id)

      { kong_id: kong_id, kong_username: kong_consumer_name, token: kong_api_key }
    end

    protected

    def kong_elb
      raise 'NotImplemented'
    end

    def kong_password
      raise 'NotImplemented'
    end

    def environment_key
      raise 'NotImplemented'
    end

    private

    def save_id_to_user(user, id)
      auth_ref_key = ConsumerAuthRef::KEYS["#{environment_key}_gateway_ref".to_sym]
      existing_auth_ref = user.consumer.consumer_auth_refs.kept.find_by(key: auth_ref_key)
      existing_auth_ref.discard if existing_auth_ref.present?
      auth_ref = ConsumerAuthRef.new(consumer: user.consumer, key: auth_ref_key, value: id)
      user.consumer.consumer_auth_refs.push(auth_ref)
      user.save!
      user.undiscard if user.discarded?
    end

    def generate_consumer_name(organization, last_name)
      "#{organization}#{last_name}".gsub(/\W/, '')
    end

    def get_or_create_consumer(consumer_name)
      begin
        return get_consumer(consumer_name)['id']
      rescue RuntimeError
        # continue if consumer not found
      end
      create_consumer(consumer_name)['id']
    end

    def handle_key_auth_flow(org, last_name, key_auth)
      kong_consumer_name = generate_consumer_name(org, last_name)
      kong_id = get_or_create_consumer(kong_consumer_name)
      current_acls = get_acls(kong_id)['data'].collect { |acl| acl['group'] }
      key_auth.map do |acl|
        add_acl(kong_id, acl) if current_acls.exclude? acl
      end
      kong_api_key = create_key(kong_id)['key']
      [kong_id, kong_consumer_name, kong_api_key]
    end

    def request(req, uri)
      kong_through_kong? ? (req['apikey'] = kong_password) : req.basic_auth('kong_admin', kong_password)
      response = @client.start(uri.host, uri.port, use_ssl: uri.to_s.start_with?('https')) do |http|
        http.request(req)
      end

      response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
      raise 'Failed to retrieve kong consumers list' unless response['ok']

      JSON.parse(response.body) unless response.body.nil?
    end

    def kong_through_kong?
      Flipper.enabled? :kong_through_kong
    end
  end
end
