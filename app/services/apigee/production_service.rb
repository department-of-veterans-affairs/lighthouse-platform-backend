# frozen_string_literal: true

module Apigee
  class ProductionService < BaseService
    protected

    def apigee_gateway
      Figaro.env.apigee_prod_gateway
    end

    def apigee_gateway_apikey
      Figaro.env.apigee_gateway_prod_apikey
    end
  end
end
