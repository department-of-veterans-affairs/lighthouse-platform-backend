# frozen_string_literal: true

module Entities
  class ApiEnvironmentEntity < Grape::Entity
    expose :id
    expose :metadata_url, as: :metadataUrl
    expose :key
    expose :label
    expose :api_intro, as: :apiIntro
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
