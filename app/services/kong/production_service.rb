# frozen_string_literal: true

module Kong
  class ProductionService < BaseService
    protected

    def kong_elb
      Figaro.env.prod_kong_elb || 'http://localhost:4003'
    end

    def kong_password
      Figaro.env.prod_kong_password
    end

    def environment_key
      'prod'
    end
  end
end
