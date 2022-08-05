# frozen_string_literal: true

module Entities
  class ApiKeyEntity < Grape::Entity
    expose :key
    expose :apiProducts
  end
end
