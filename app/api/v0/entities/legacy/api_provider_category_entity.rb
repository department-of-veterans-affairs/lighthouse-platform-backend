# frozen_string_literal: true

module V0
  module Entities
    module Legacy
      class ApiProviderCategoryEntity < Grape::Entity
        expose :name, documentation: { type: String }
        expose :name, as: :properName, documentation: { type: String }
        expose :api_metadatum, as: :apis, using: V0::Entities::Legacy::ApiProviderEntity
        expose :content, documentation: { type: String } do |_entity|
          'something here' # TODO: need to actually store the markdown from the portal
        end
      end
    end
  end
end
