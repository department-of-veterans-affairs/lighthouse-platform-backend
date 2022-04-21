# frozen_string_literal: true

class SlackService
  def alert_slack(webhook, message)
    uri = URI.parse(webhook)
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = message.to_json
    req['Content-type'] = 'application/json'
    client.request(req)
  end
end
