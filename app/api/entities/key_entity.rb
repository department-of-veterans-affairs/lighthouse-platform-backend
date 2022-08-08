# frozen_string_literal: true

module Entities
  class KeyEntity < Grape::Entity
    expose :keys, if: ->(key, _options) { key[:keys].present? }
    expose :clientId, if: ->(key, _options) { key[:clientId].present? }
    expose :clientSecret, if: ->(key, _options) { key[:clientSecret].present? }
    expose :apiProducts
  end
end
