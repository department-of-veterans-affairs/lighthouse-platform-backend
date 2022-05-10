# frozen_string_literal: true

module Entities
  class ConsumerAuthRefEntity < Grape::Entity
    expose :id
    expose :key
    expose :value
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
