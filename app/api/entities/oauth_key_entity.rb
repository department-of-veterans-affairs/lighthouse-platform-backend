# frozen_string_literal: true

module Entities
  class OauthKeyEntity < Grape::Entity
    expose :apiKey, with: Entities::ApiKeyEntity, if: ->(key, _options) { key[:apiKey].present? }
    expose :oAuthAcg, with: Entities::OauthEntity, if: ->(key, _options) { key[:oAuthAcg].present? }
    expose :oAuthCcg, with: Entities::OauthEntity, if: ->(key, _options) { key[:oAuthCcg].present? }
  end
end
