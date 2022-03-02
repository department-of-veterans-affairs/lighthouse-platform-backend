# frozen_string_literal: true

module V0
  module Entities
    class ApiEntity < Grape::Entity
      expose :id
      expose :name
      expose :acl
      expose :auth_server_access_key, as: :authServerAccessKey
      expose :api_ref, as: :ref, using: V0::Entities::ApiRefEntity
      expose :api_environments, as: :environments, using: V0::Entities::ApiEnvironmentEntity
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end
end
