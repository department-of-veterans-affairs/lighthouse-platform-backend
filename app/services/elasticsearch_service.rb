# frozen_string_literal: true

class ElasticsearchService
  attr_reader :client

  def initialize
    @client = Net::HTTP
    @es_base = Figaro.env.es_endpoint || 'http://localhost:9200'
    @uri = URI.parse("#{@es_base}/_search")
  end

  def seed_elasticsearch
    uri = URI.parse("#{@es_base}/_bulk")
    req = Net::HTTP::Post.new(uri)
    req.body = File.read(File.join(File.dirname(__FILE__), '../../spec/support/elasticsearch/mock_logs.json'))
    request(req, uri)
  end

  def first_successful_call(consumer)
    req = Net::HTTP::Get.new(@uri)
    kong_id = consumer[:sandbox_gateway_ref]
    cid = consumer[:sandbox_oauth_ref]
    first_success_query(kong_id, cid)
    req.body = @query.to_json
    response = request(req, @uri)
    if response['hits']['total']['value'].positive?
      first_call = parse_times(response)
      convert_time(first_call)
    end
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

  def convert_time(timestamp)
    timestamp.strftime('%B %d, %Y')
  end

  def parse_times(response)
    [].tap do |time|
      response['hits']['hits'].map do |log|
        time << Date.iso8601(log['_source']['@timestamp'])
      end
    end.min
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
