# frozen_string_literal: true

module Apigee
  class SandboxService < BaseService
    protected

    def apigee_gateway
      Figaro.env.apigee_gateway
    end

    def apigee_gateway_apikey
      Figaro.env.apigee_gateway_apikey
    end
  end
end
