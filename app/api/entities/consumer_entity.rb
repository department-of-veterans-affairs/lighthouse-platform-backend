# frozen_string_literal: true

module Entities
  class ConsumerEntity < Grape::Entity
    expose :id
    expose :description
    expose :tos_accepted_at, as: :tosAcceptedAt
    expose :tos_version, as: :tosVersion
    expose :consumer_auth_refs, as: :authRefs, using: Entities::ConsumerAuthRefEntity
    expose :organization
    expose :apis, using: Entities::ApiEntity
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
