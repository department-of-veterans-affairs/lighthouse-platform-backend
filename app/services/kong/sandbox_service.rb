# frozen_string_literal: true

module Kong
  class SandboxService < BaseService
    protected

    def kong_elb
      Figaro.env.kong_elb || 'http://localhost:4001'
    end

    def kong_password
      Figaro.env.kong_password
    end

    def environment_key
      'sandbox'
    end
  end
end
