# frozen_string_literal: true

module Entities
  class KeysEntity < Grape::Entity
    expose :clientId
    expose :clientSecret
    expose :key
    expose :apiProducts
  end
end
