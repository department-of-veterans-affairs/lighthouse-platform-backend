# frozen_string_literal: true

module Okta
  class ProductionService < BaseService
    protected

    def idme_group
      Figaro.env.prod_idme_group_id
    end

    def okta_api_endpoint
      Figaro.env.prod_okta_api_endpoint
    end

    def okta_token
      Figaro.env.prod_okta_token
    end

    def va_redirect
      Figaro.env.prod_okta_redirect_url
    end

    def environment_key
      'prod'
    end
  end
end
