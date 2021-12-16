# frozen_string_literal: true

require 'socksify/http'

class ElasticsearchService
  def initialize
    socks_host = ENV['SOCKS_HOST'] || 'localhost'
    @base = ENV['es_endpoint']
    @client = Net::HTTP.SOCKSProxy(socks_host, 2001)
  end

  def get_four_twenty_nine
    uri = URI.parse("#{@base}/_search")
    req = Net::HTTP::Get.new(uri)
    req.body = four_twenty_nine_error.to_json
    request(req, uri)
  end

  def get_four_oh_three
    uri = URI.parse("#{@base}/_search")
    req = Net::HTTP::Get.new(uri)
    req.body = four_oh_three_error.to_json
    request(req, uri)
  end

  def get_consumer_twenty_nine(gateway_ref)
    uri = URI.parse("#{@base}/_search")
    req = Net::HTTP::Get.new(uri)
    req.body = consumer_by_status_code(429, gateway_ref).to_json
    request(req, uri)
  end

  def get_consumer_four_oh_three(gateway_ref)
    uri = URI.parse("#{@base}/_search")
    req = Net::HTTP::Get.new(uri)
    req.body = consumer_by_status_code(403, gateway_ref).to_json
    request(req, uri)
  end

  private

  def request(req, uri)
    req['Content-type'] = 'application/json'
    req['kbn-xsrf'] = true
    resp = @client.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    return JSON.parse(resp.body) unless resp.body.nil?

    # If there's no resp.body we should check if the resp object returned is
    # successful or not. (all 2xx statuses are subclasses of Net::HTTPSuccess)
    resp.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
  end

  def four_twenty_nine_error
    {
      query: {
        bool: {
          filter: [
            {
              range: {
                '@timestamp': {
                  gte: 'now-30d',
                  lte: 'now'
                }
              }
            }
          ],
          must: [
            {
              match: {
                'response.status': {
                  query: 429
                }
              }
            }
          ]
        }
      }
    }
  end

  def four_oh_three_error
    {
      query: {
        bool: {
          filter: [
            {
              range: {
                '@timestamp': {
                  gte: 'now-6h',
                  lte: 'now'
                }
              }
            }
          ],
          must: [
            {
              match: {
                'response.status': {
                  query: 403
                }
              }
            }
          ]
        }
      }
    }
  end

  def consumer_by_status_code(status_code, gateway_ref)
    {
      query: {
        bool: {
          filter: [
            {
              range: {
                '@timestamp': {
                  gte: 'now-30d',
                  lte: 'now'
                }
              }
            }
          ],
          must: [
            {
              match: {
                'response.status': {
                  query: status_code.to_s
                }
              }
            },
            {
              match: {
                'consumer.id': {
                  query: gateway_ref.to_s
                }
              }
            }
          ]
        }
      }
    }
  end
end
