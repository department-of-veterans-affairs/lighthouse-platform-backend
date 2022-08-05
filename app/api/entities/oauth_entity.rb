# frozen_string_literal: true

module Entities
  class OauthEntity < Grape::Entity
    expose :clientId
    expose :clientSecret, if: ->(key, _options) { key[:clientSecret].present? }
    expose :apiProducts
  end
end
