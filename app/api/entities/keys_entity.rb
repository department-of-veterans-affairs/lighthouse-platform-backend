# frozen_string_literal: true

module Entities
  class KeysEntity < Grape::Entity
    expose :apiKey, with: Entities::KeyEntity, if: ->(key, _options) { key[:apiKey].present? }
    expose :oAuthAcg, with: Entities::KeyEntity, if: ->(key, _options) { key[:oAuthAcg].present? }
    expose :oAuthCcg, with: Entities::KeyEntity, if: ->(key, _options) { key[:oAuthCcg].present? }
  end
end
