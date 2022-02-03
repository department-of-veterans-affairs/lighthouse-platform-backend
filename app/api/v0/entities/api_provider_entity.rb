# frozen_string_literal: true

module V0
  module Entities
    class ApiProviderEntity < Grape::Entity
      format_with(:iso_timestamp, &:iso8601)

      expose :id, documentation: { type: String } do |entity|
        entity.name.underscore.camelize(:lower)
      end
      expose :description, documentation: { type: String } do |entity|
        entity.api_metadatum.description
      end
      expose :docSources do |entity, options|
        api_environments = if options[:environment].present?
                             entity.api_environments.select do |api_environment|
                               api_environment.environment.name == options[:environment]
                             end
                           else
                             entity.api_environments
                           end

        api_environments.map { |api_environment| { metadataUrl: api_environment.metadata_url } }
      end
      expose :enabledByDefault do |entity|
        entity.api_metadatum.enabled_by_default
      end
      expose :name, documentation: { type: String } do |entity|
        entity.api_metadatum.display_name
      end
      expose :openData do |entity|
        entity.api_metadatum.open_data
      end
      expose :urlFragment, documentation: { type: String } do |entity|
        entity.name.underscore
      end
      expose :vaInternalOnly do |entity|
        entity.api_metadatum.va_internal_only
      end

      with_options(format_with: :iso_timestamp) do
        expose :created_at, as: :createdAt
      end

      # TODO:
      #  expose :releaseNotes  <-- separate endpoint maybe?
      #  expose :oAuth
      #  expose :oAuthInfo
      #  expose :oAuthTypes
      #  expose :lastProdAccessStep  <-- maybe figure out on the frontend somehow?
      #  expose :veteranRedirect  <-- notification at the top of the documents page
      #  expose :category
    end
  end
end
