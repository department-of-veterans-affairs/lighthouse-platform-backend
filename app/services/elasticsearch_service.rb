# frozen_string_literal: true

class ElasticsearchService
  attr_reader :client

  def initialize
    @client = Net::HTTP
    @es_base = Figaro.env.es_endpoint || 'http://localhost:9200'
  end

  def seed_elasticsearch
    uri = URI.parse("#{@es_base}/_bulk")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = File.read(File.join(File.dirname(__FILE__), '../../spec/support/elasticsearch/mock_logs.json'))
    request(req, uri)
  end

  private

  def request(req, uri)
    response = @client.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
    raise 'Failed to retrieve data from Elasticsearch' unless response['ok']

    JSON.parse(response.body) unless response.body.nil?
  end
end
