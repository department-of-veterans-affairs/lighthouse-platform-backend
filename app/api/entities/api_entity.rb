# frozen_string_literal: true

module Entities
  class ApiEntity < Grape::Entity
    expose :id
    expose :name
    expose :acl
    expose :auth_server_access_key, as: :authServerAccessKey
    expose :api_ref, as: :ref, using: Entities::ApiRefEntity
    expose :api_environments, as: :environments, using: Entities::ApiEnvironmentEntity
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
