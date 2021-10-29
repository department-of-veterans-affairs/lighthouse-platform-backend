# frozen_string_literal: true

require 'net/http'
require 'socksify/http'

class KongService
  attr_reader :client

  def initialize
    @kong_elb = ENV['KONG_ELB'] || 'http://localhost:4001'
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
    req.basic_auth 'kong_admin', ENV['kong_password']
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    return JSON.parse(response.body) unless response.body.nil?

    # If there's no response.body we should check if the response object returned is
    # successful or not. (all 2xx statuses are subclasses of Net::HTTPSuccess)
    response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
  end
end
