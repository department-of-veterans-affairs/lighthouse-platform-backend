# frozen_string_literal: true

module V0
  module Entities
    module Legacy
      class ApiProviderEntity < Grape::Entity
        expose :altID, documentation: { type: String } do |entity|
          entity.api.api_ref.name
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
        expose :lastProdAccessStep do |entity|
          if entity.open_data && !entity.va_internal_only
            2
          elsif !entity.open_data && entity.va_internal_only
            3
          else
            4
          end
        end
        expose :name, documentation: { type: String } do |entity|
          entity.display_name
        end
        expose :openData do |entity|
          entity.open_data
        end
        expose :releaseNotes do |entity|
          entity.api_release_notes.map do |release_note|
            "### #{release_note.date.strftime("%B %d, %Y")}\n\n#{release_note.content}"
          end.join("\n\n---\n\n")
        end
        expose :urlFragment do |entity|
          entity.api.api_ref.name.underscore
        end
        expose :vaInternalOnly do |entity|
          entity.va_internal_only
        end
        expose :oAuth do |entity|
          entity.oauth_info.present?
        end
        expose :oauth_info, as: :oAuthInfo do |entity|
          if entity.oauth_info.present?
            JSON.parse(entity.oauth_info)
          else
            nil
          end
        end
        expose :oAuthTypes do |entity|
          if entity.oauth_info.present?
            types = []
            oauth_information = JSON.parse(entity.oauth_info)
            types.push('AuthorizationCodeGrant') if oauth_information['acgInfo'].present?
            types.push('ClientCredentialsGrant') if oauth_information['ccgInfo'].present?
          else
            nil
          end
        end
        expose :veteranRedirect do |entity|
          if entity.api_category.veteran_redirect_link_url.present?
            {
              linkUrl: entity.api_category.veteran_redirect_link_url,
              linkText: entity.api_category.veteran_redirect_link_text,
              message: entity.api_category.veteran_redirect_message
            }
          else
            nil
          end
        end
      end
    end
  end
end
