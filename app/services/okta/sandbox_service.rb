# frozen_string_literal: true

module Okta
  class SandboxService < BaseService
    protected

    def idme_group
      Figaro.env.idme_group_id
    end

    def okta_api_endpoint
      Figaro.env.okta_api_endpoint
    end

    def okta_token
      Figaro.env.okta_token
    end

    def va_redirect
      Figaro.env.okta_redirect_url
    end
  end
end
