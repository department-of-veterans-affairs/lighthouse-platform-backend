# frozen_string_literal: true

module V0
  module Entities
    class ApiProviderEntity < Grape::Entity
      format_with(:iso_timestamp, &:iso8601)

      expose :id, documentation: { type: String } do |entity|
        entity.name
      end
      expose :api_category, as: :category, documentation: { type: String } do |entity|
        { name: entity.api_metadatum.api_category&.name }
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
      expose :name, documentation: { type: String } do |entity|
        entity.api_metadatum.display_name
      end
      expose :openData do |entity|
        entity.api_metadatum.open_data
      end
      expose :vaInternalOnly do |entity|
        entity.api_metadatum.va_internal_only
      end
      expose :oauth_info, as: :oAuthInfo do |entity|
        entity.api_metadatum.oauth_info
      end

      with_options(format_with: :iso_timestamp) do
        expose :created_at, as: :createdAt
      end
    end
  end
end
