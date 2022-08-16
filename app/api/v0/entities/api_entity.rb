# frozen_string_literal: true

module V0
  module Entities
    class ApiEntity < Grape::Entity
      expose :name
      expose :status
      expose :authTypes do |api, _options|
        api.locate_auth_types
      end
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end
end
