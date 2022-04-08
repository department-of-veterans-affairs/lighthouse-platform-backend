# frozen_string_literal: true

module Kong
  class SandboxService < BaseService

    protected

    def set_kong_elb
      Figaro.env.kong_elb || 'http://localhost:4001'
    end
  
    def set_kong_password
      Figaro.env.kong_password
    end

  end
end