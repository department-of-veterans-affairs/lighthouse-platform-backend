# frozen_string_literal: true

module Entities
  class ApiCategoryEntity < Grape::Entity
    expose :name
    expose :id
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
