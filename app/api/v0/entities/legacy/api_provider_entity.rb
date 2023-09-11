# frozen_string_literal: true

module V0
  module Entities
    module Legacy
      class ApiProviderEntity < Grape::Entity
        expose :altID, documentation: { type: String } do |entity|
          entity.api.api_ref.name if entity.api.api_ref.present?
        end
        expose :description, documentation: { type: String }
        expose :docSources do |entity, options|
          api_environments = if options[:environment].present?
                               entity.api.api_environments.select do |api_environment|
                                 api_environment.environment.name == options[:environment]
                               end
                             else
                               entity.api.api_environments
                             end

          api_environments.map do |api_environment|
            {
              metadataUrl: api_environment.metadata_url
            }
          end
        end
        expose :enabledByDefault, documentation: { type: String } do |_entity|
          true
        end
        expose :lastProdAccessStep do |entity|
          if entity.open_data && entity.va_internal_only.blank?
            2
          elsif !entity.open_data && entity.va_internal_only.present?
            3
          else
            4
          end
        end
        expose :display_name, as: :name, documentation: { type: String }
        expose :open_data, as: :openData
        expose :releaseNotes do |entity|
          entity.api_release_notes.kept.order(date: :desc).map do |release_note|
            "### #{release_note.date.strftime('%B %d, %Y')}\n\n#{release_note.content}"
          end.join("\n\n---\n\n")
        end
        expose :url_fragment, as: :urlFragment
        expose :va_internal_only, as: :vaInternalOnly,
                                  if: ->(instance, _options) { instance.va_internal_only.present? }
        expose :oAuth do |entity|
          entity.oauth_info.present?
        end
        expose :oauth_info, as: :oAuthInfo do |entity|
          JSON.parse(entity.oauth_info) if entity.oauth_info.present?
        end
        expose :oAuthTypes do |entity|
          if entity.oauth_info.present?
            types = []
            oauth_information = JSON.parse(entity.oauth_info)
            types.push('AuthorizationCodeGrant') if oauth_information['acgInfo'].present?
            types.push('ClientCredentialsGrant') if oauth_information['ccgInfo'].present?

            types
          end
        end
        expose :block_sandbox_form, as: :blockSandboxForm
        expose :veteranRedirect do |entity|
          if entity.veteran_redirect_link_url.present?
            {
              linkUrl: entity.veteran_redirect_link_url,
              linkText: entity.veteran_redirect_link_text,
              message: entity.veteran_redirect_message
            }
          end
        end
        expose :deactivation_info, if: ->(entity) { entity.deactivation_info.present? },
                                   as: :deactivationInfo do |entity|
          JSON.parse(entity.deactivation_info)
        end
        expose :overview_page_content, as: :overviewPageContent
        expose :restricted_access_details, as: :restrictedAccessDetails
        expose :restricted_access_toggle, as: :restrictedAccessToggle
        expose :url_slug, as: :urlSlug
      end
    end
  end
end
