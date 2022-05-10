# frozen_string_literal: true

class ElasticsearchService
  attr_reader :client

  def initialize
    @client = Net::HTTP
    @es_base = Figaro.env.es_endpoint || 'http://localhost:9200'
    @uri = URI.parse("#{@es_base}/_search")
  end

  def search_connection
    req = Net::HTTP::Get.new(@uri)
    request(req, @uri)
  end

  def first_successful_call(consumer)
    req = Net::HTTP::Get.new(@uri)
    kong_id = consumer.consumer_auth_refs.find_by(key: ConsumerAuthRef::KEYS[:sandbox_gateway_ref])&.value
    cid = consumer.consumer_auth_refs.find_by(key: ConsumerAuthRef::KEYS[:sandbox_acg_oauth_ref])&.value
    first_success_query(kong_id, cid)
    req.body = @query.to_json
    response = request(req, @uri)
    if response['hits']['total']['value'].positive?
      first_call = parse_times(response)
      { first_sandbox_interaction_at: convert_time(first_call) }
    end
  end

  private

  def request(req, uri)
    req['Content-type'] = 'application/json'
    req['kbn-xsrf'] = true
    response = @client.start(uri.host, uri.port, use_ssl: uri.to_s.start_with?('https')) do |http|
      http.request(req)
    end

    response.tap { |res| res['ok'] = res.is_a? Net::HTTPSuccess }
    raise 'Failed to retrieve data from Elasticsearch' unless response['ok']

    JSON.parse(response.body) unless response.body.nil?
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
