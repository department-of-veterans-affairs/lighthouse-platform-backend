# frozen_string_literal: true

module V0
  module Entities
    class ConsumerApiEntity < Grape::Entity
      expose :id
      expose :name, documentation: { type: 'String' }
      expose :api_metadatum, using: Entities::ApiMetadatumEntity
      expose :api_ref, as: :ref, using: Entities::ApiRefEntity
    end
  end
end
