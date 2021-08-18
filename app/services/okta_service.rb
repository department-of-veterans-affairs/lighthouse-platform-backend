# frozen_string_literal: true

require 'oktakit'

class OktaService
  def initialize
    @client = Oktakit::Client.new(token: ENV['okta_token'], api_endpoint: ENV['okta_api_endpoint'])
  end

  def list_applications
    resp, = @client.list_applications
    resp.map(&:to_h)
  end
end
