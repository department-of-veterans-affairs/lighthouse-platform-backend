# frozen_string_literal: true

require 'net/http'
require 'socksify/http'

class KongService
  attr_reader :client

  def initialize(env = nil)
    @env = env
    @client = Figaro.env.socks_host.present? ? Net::HTTP.SOCKSProxy(Figaro.env.socks_host, 2001) : Net::HTTP
    @kong_elb = set_kong_elb
  end

  # seeds local gateway for testing purposes
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
  # end seeds

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

  def create_key(consumer)
    uri = URI.parse("#{@kong_elb}/consumers/#{consumer}/key-auth")
    req = Net::HTTP::Post.new(uri)
    request(req, uri)
  end

  def consumer_signup(user, key_auth)
    raise 'Missing key auth APIs' if key_auth.empty?

    kong_id, kong_consumer_name, kong_api_key = handle_key_auth_flow(user.consumer.organization,
                                                                     user.last_name,
                                                                     key_auth)

    { kong_id: kong_id, kongUsername: kong_consumer_name, token: kong_api_key }
  end

  private

  def generate_consumer_name(organization, last_name)
    # Prepend LPB- during test phase to define consumers from LPB
    "LPB-#{"#{organization}#{last_name}".gsub(/\W/, '')}"
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

  def set_kong_elb
    if @env.nil?
      Figaro.env.kong_elb || 'http://localhost:4001'
    else
      Figaro.env.prod_kong_elb || 'http://localhost:4003'
    end
  end

  def set_kong_password
    return nil if Figaro.env.kong_password.blank?

    if @env.nil?
      Figaro.env.kong_password
    else
      Figaro.env.prod_kong_password
    end
  end

  def request(req, uri)
    req.basic_auth 'kong_admin', set_kong_password
    response = @client.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
    raise 'Failed to retrieve kong consumers list' unless response['ok']

    JSON.parse(response.body) unless response.body.nil?
  end
end
