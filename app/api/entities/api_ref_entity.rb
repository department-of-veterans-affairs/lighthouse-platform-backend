# frozen_string_literal: true

module Entities
  class ApiRefEntity < Grape::Entity
    expose :id
    expose :name
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
