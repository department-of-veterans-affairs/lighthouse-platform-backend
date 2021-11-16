# frozen_string_literal: true

require 'net/http'
require 'socksify/http'

class KongService
  attr_reader :client

  def initialize
    @client = if Figaro.env.socks_host.present?
                Net::HTTP.SOCKSProxy(Figaro.env.socks_host, 2001)
              else
                Net::HTTP
              end
    @kong_elb = Figaro.env.kong_elb || 'http://localhost:4001'
  end

  def seed_kong
    seed_kong_consumers
  end

  def construct_consumer_list
    %w[lighthouse-consumer kong-consumer]
  end

  def seed_kong_consumers
    construct_consumer_list.map do |consumer|
      uri = URI.parse("#{@kong_elb}/consumers")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { username: consumer }.to_json
      request(req, uri)
    end
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

  private

  def request(req, uri)
    req.basic_auth 'kong_admin', Figaro.env.kong_password if Figaro.env.kong_password.present?
    response = @client.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
    raise 'Failed to retrieve kong consumers list' unless response['ok']

    JSON.parse(response.body) unless response.body.nil?
  end
end
