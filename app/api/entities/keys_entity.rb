# frozen_string_literal: true

module Entities
  class KeysEntity < Grape::Entity
    expose :key
    expose :clientId
    expose :clientSecret
    expose :apiProducts
  end
end
