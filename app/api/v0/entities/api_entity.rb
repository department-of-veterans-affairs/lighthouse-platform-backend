# frozen_string_literal: true

module V0
  module Entities
    class ApiEntity < Grape::Entity
      expose :name
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end
end
