# frozen_string_literal: true

module V0
  module Entities
    module Legacy
      class ApiProviderEntity < Grape::Entity
        expose :altID, documentation: { type: String } do |entity|
          entity.api.name.underscore.camelize(:lower)
        end
        expose :description, documentation: { type: String } do |entity|
          entity.description
        end
        expose :docSources do |entity, options|
          api_environments = if options[:environment].present?
                               entity.api.api_environments.select do |api_environment|
                                 api_environment.environment.name == options[:environment]
                               end
                             else
                               entity.api.api_environments
                             end

          api_environments.map { |api_environment| { metadataUrl: api_environment.metadata_url } }
        end
        expose :enabledByDefault, documentation: { type: String } do |_entity|
          true
        end
        expose :lastProdAccessStep do |_entity|
          nil # TODO: unsure on how to do this atm
        end
        expose :name, documentation: { type: String } do |entity|
          entity.display_name
        end
        expose :openData do |entity|
          entity.open_data
        end
        expose :releaseNotes do |_entity|
          nil # TODO: unsure on how to do this atm
        end
        expose :urlFragment do |entity|
          entity.api.name.underscore.camelize(:lower)
        end
        expose :vaInternalOnly do |entity|
          entity.va_internal_only
        end
        expose :oAuth do |entity|
          entity.oauth_info.present?
        end
        expose :oauth_info, as: :oAuthInfo do |entity|
          entity.oauth_info
        end
        expose :oAuthTypes do |entity|
          []
        end
      end
    end
  end
end
