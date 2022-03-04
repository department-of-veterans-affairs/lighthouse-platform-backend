# frozen_string_literal: true

class ElasticsearchService
  attr_reader :client

  def initialize
    @client = Net::HTTP
    @es_base = Figaro.env.es_endpoint || 'http://localhost:9200'
  end

  def seed_elasticsearch
    uri = URI.parse("#{@es_base}/_bulk")
    req = Net::HTTP::Post.new(uri)
    req.body = File.read(File.join(File.dirname(__FILE__), '../../spec/support/elasticsearch/mock_logs.json'))
    request(req, uri)
  end

  def first_successful_call(user)
    uri = URI.parse("#{@es_base}/_search")
    req = Net::HTTP::Get.new(uri)
    kong_id = user.consumer.sandbox_gateway_ref
    cid = user.consumer.sandbox_oauth_ref
    first_success_query(kong_id, cid)
    req.body = @query.to_json
    response = request(req, uri)
    convert_time(response) if response['hits']['total']['value'].positive?
  end

  private

  def request(req, uri)
    req['Content-type'] = 'application/json'
    req['kbn-xsrf'] = true
    response = @client.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
    raise 'Failed to retrieve data from Elasticsearch' unless response['ok']

    JSON.parse(response.body) unless response.body.nil?
  end

  def extract_timestamp(response)
    response['hits']['hits'].first['_source']['@timestamp']
  end

  def convert_time(response)
    timestamp = extract_timestamp(response)
    Date.iso8601(timestamp).strftime("%B %d, %Y")
  end

  def query_builder(body)
    @query = {
      query: body
    }
  end

  def first_success_query(kong_id, cid)
    ids = build_consumer_ids(kong_id, cid)
    body = {
      bool: {
        must: [
          two_hundred_status,
          locate_ids(ids)
        ]
      }
    }
    query_builder(body)
  end

  def build_consumer_ids(kong_id, cid)
    if cid && kong_id
      "jwt_claims.cid:#{cid} OR consumer.id:#{kong_id}"
    elsif kong_id
      "consumer.id:#{kong_id}"
    else
      "jwt_claims.cid:#{cid}"
    end
  end

  def two_hundred_status
    {
      match: { 'response.status': 200 }
    }
  end

  def locate_ids(ids)
    {
      query_string: {
        query: ids
      }
    }
  end
end
