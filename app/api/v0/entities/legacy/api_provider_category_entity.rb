# frozen_string_literal: true

module V0
  module Entities
    module Legacy
      class ApiProviderCategoryEntity < Grape::Entity
        expose :name, documentation: { type: String }
        expose :name, as: :properName, documentation: { type: String }
        expose :api_metadatum, as: :apis do |entity, options|
          V0::Entities::Legacy::ApiProviderEntity.represent(entity.api_metadatum, environment: options[:environment])
        end
        expose :content do |entity|
          response = { consumerDocsLinkText: entity.consumer_docs_link_text,
                       shortDescription: entity.short_description,
                       quickstart: entity.quickstart,
                       veteranRedirect: {
                         linkUrl: entity.veteran_redirect_link_url,
                         linkText: entity.veteran_redirect_link_text,
                         message: entity.veteran_redirect_message
                       },
                       overview: entity.overview }
          response[:veteranRedirect] = nil if entity.veteran_redirect_link_url.blank?

          response
        end
      end
    end
  end
end
