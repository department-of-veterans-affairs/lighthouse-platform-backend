# frozen_string_literal: true

module Kong
  class ProductionService < BaseService
    protected

    def set_kong_elb
      Figaro.env.prod_kong_elb || 'http://localhost:4003'
    end

    def set_kong_password
      Figaro.env.prod_kong_password
    end
  end
end
