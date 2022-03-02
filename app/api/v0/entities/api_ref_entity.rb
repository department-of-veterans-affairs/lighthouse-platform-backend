# frozen_string_literal: true

module V0
  module Entities
    class ApiRefEntity < Grape::Entity
      expose :id
      expose :name
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end
end
