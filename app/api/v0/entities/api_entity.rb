# frozen_string_literal: true

module V0
  module Entities
    class ApiEntity < Grape::Entity
      expose :name
      expose :status
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
      expose :auth_type do |api, _options|
        api.locate_auth_types
      end
    end
  end
end
