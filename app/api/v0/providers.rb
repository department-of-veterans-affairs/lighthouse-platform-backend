# frozen_string_literal: true

module V0
  class Providers < V0::Base
    version 'v0'

    helpers do
      def oauth_to_json
        oauth = params['api_metadatum_attributes']['oauth_info'].to_json
        params['api_metadatum_attributes']['oauth_info'] = oauth
        params
      end

      def initialize_user
        users = User.where('LOWER(email) = ?', params[:email].downcase.strip)
        user = users.present? ? users.first : User.new(email: params[:email].downcase.strip)
        create_internal_consumer(user) unless user.persisted?
        user
      end

      def create_internal_consumer(user)
        user.assign_attributes(first_name: params[:firstName], last_name: params[:lastName])
        user.save
        user.consumer = Consumer.create(description: 'Internal User', organization: 'Lighthouse')
      end
    end

    resource 'providers' do
      desc 'Return list of API providers', {
        headers: {
          'Authorization' => {
            required: false
          }
        }
      }
      params do
        optional :status, type: String,
                          values: %w[active inactive],
                          allow_blank: true
        optional :authType, type: String, values: %w[apikey oauth oauth/acg oauth/ccg]
      end
      get '/' do
        validate_token(Scope.provider_read)

        apis = Api

        if params[:authType].present?
          auth_types = params[:authType].split('/')
          apis = Api.auth_type(auth_types.first)
        end

        apis = apis.kept if params[:status] == 'active'
        apis = apis.discarded if params[:status] == 'inactive'
        apis = apis.displayable
        apis = apis.order(:name)
        if params[:authType].present? && auth_types.length > 1
          apis = apis.filter do |api|
            api.locate_auth_types.include?(params[:authType])
          end
        end

        present apis, with: V0::Entities::ApiEntity
      end

      params do
        requires :providerName, type: String, allow_blank: false
      end
      get '/:providerName' do
        validate_token(Scope.consumer_read)

        api = Api.find_by(name: params[:providerName])
        raise 'Invalid API' unless api.kept?

        present api, with: V0::Entities::ApiEntity
      end

      desc 'Add an API to the developer portal' do
        detail <<-DETAILTEXT
          # Environment and Scopes
          These fields are CSV. Ignore what the placeholder text from the textarea says. It's wrong.

          # Sample values (New Demo API)
          ## Basic details
          name: new-demo
          - lowercase with dashes of display name without API

          api_environments_attributes[metadata_url]: https://url.to.docserver/metadata.json

          api_environments_attributes[environments_attributes][name]: sandbox,production

          api_ref_attributes[name]: newDemo
          - camelCase of display name without API

          acl: new-demo-acl

          auth_server_access_key: AUTHZ_SERVER_NEW_DEMO
          - CCG APIs, list the key as above and the system will append _CCG when referencing the ENV variables below
          - https://github.com/department-of-veterans-affairs/lighthouse-platform-backend-deployment/blob/master/ecs/ecs-params.yml

          api_metadatum_attributes[description]: Card description talking about New Demo API

          api_metadatum_attributes[display_name]: New Demo API

          api_metadatum_attributes[open_data]: true/false

          api_metadatum_attributes[va_internal_only]: Select a value
          - You may have to set this to something incorrect and then reset in /platform-backend/admin/database/api_metadatum

          api_metadatum_attributes[url_fragment]: new-demo

          api_metadatum_attributes[api_category_attributes][id]: 1
          - Category id in this environment found on /platform-backend/admin/database/api_category

          api_metadatum_attributes[overview_page_content]: Some nice content...
          - Markdown content for the "overview page" on DevPortal

          api_metadatum_attributes[url_slug]: new-demo

          api_metadatum_attributes[restricted_access_toggle]: true/false

          api_metadatum_attributes[restricted_access_details]: Why is the API restricted?
          - Verbiage indicating why the API is restricted.

          api_metadatum_attributes[block_sandbox_form]: Block the sandbox access request form.

          ## Auth Info
          ### CCG
          - From the .well-known openid-configuration
          - https://api.va.gov/oauth2/claims/system/v1/.well-known/openid-configuration
          - https://sandbox-api.va.gov/oauth2/claims/system/v1/.well-known/openid-configuration
          - When on prod, all values except for productionAud and productionWellKnownConfig should come
            from the sandbox .well-known config file

          api_metadatum_attributes[oauth_info][ccgInfo][baseAuthPath]: /oauth2/claims/system/v1
          - Remove the domain from the front and /token from the end of token_endpoint
          - 'https://api.va.gov/oauth2/claims/system/v1/token' -> '/oauth2/claims/system/v1'

          api_metadatum_attributes[oauth_info][ccgInfo][productionAud]: ausajojxqhTsDSVlA297
          - Last url segment taken from the issuer property
          - 'https://va.okta.com/oauth2/ausajojxqhTsDSVlA297' -> 'ausajojxqhTsDSVlA297'

          api_metadatum_attributes[oauth_info][ccgInfo][productionWellKnownConfig]:
          - https://api.va.gov/oauth2/claims/system/v1/.well-known/openid-configuration

          api_metadatum_attributes[oauth_info][ccgInfo][sandboxAud]: ausdg7guis2TYDlFe2p7
          - Last url segment taken from the issuer property
          - 'https://deptva-eval.okta.com/oauth2/ausdg7guis2TYDlFe2p7' -> 'ausdg7guis2TYDlFe2p7'

          api_metadatum_attributes[oauth_info][ccgInfo][sandboxWellKnownConfig]:
          - https://sandbox-api.va.gov/oauth2/claims/system/v1/.well-known/openid-configuration

          api_metadatum_attributes[oauth_info][ccgInfo][scopes]: claims.read,claims.write
          - CSV list of scopes provided in ticket, all must be in scopes_supported property in config

          ### ACG
          - From the .well-known openid-configuration
          - https://api.va.gov/oauth2/health/v1/.well-known/openid-configuration
          - https://sandbox-api.va.gov/oauth2/health/v1/.well-known/openid-configuration
          - When on prod, all values except for productionAud and productionWellKnownConfig should come
            from the sandbox .well-known config file

          api_metadatum_attributes[oauth_info][acgInfo][baseAuthPath]: /oauth2/health/v1
          - Remove the domain from the front and /token from the end of token_endpoint
          - 'https://api.va.gov/oauth2/health/v1/token' -> '/oauth2/health/v1'

          api_metadatum_attributes[oauth_info][acgInfo][productionWellKnownConfig]:
          - https://api.va.gov/oauth2/health/v1/.well-known/openid-configuration

          api_metadatum_attributes[oauth_info][acgInfo][sandboxWellKnownConfig]:
          - https://sandbox-api.va.gov/oauth2/health/v1/.well-known/openid-configuration

          api_metadatum_attributes[oauth_info][acgInfo][scopes]: patient/AllergyIntolerance.read,patient/Appointment.read,etc...
          - CSV list of scopes provided in ticket, all must be in scopes_supported property in config

          ## Veteran redirect

          api_metadatum_attributes[veteran_redirect][veteran_redirect_link_text]: Click Here

          api_metadatum_attributes[veteran_redirect][veteran_redirect_link_url]: https://www.va.gov

          api_metadatum_attributes[veteran_redirect][veteran_redirect_message]: Longer message about where Veterans should go
        DETAILTEXT
      end
      params do
        requires :name, type: String, allow_blank: false, description: 'Name of API Provider'
        requires :api_environments_attributes, type: Hash do
          requires :metadata_url, type: String, allow_blank: false,
                                  description: 'Metadata URL typically served by Docserver'
          requires :environments_attributes, type: Hash do
            requires :name, type: Array[String], allow_blank: false,
                            description: 'Available API Environments<br /><h2>Comma separated!<h2>',
                            values: ->(v) { %w[sandbox production].include?(v) },
                            coerce_with: ->(v) { v.split(',') }
          end
        end
        requires :api_ref_attributes, type: Hash do
          requires :name, type: String, allow_blank: false,
                          description: 'Reference name for developer portal'
        end
        optional :acl, type: String, allow_blank: false, description: 'Kong ACL for the API'
        optional :auth_server_access_key, type: String, allow_blank: false,
                                          description: 'ID for the associated Okta Auth Server'
        requires :api_metadatum_attributes, type: Hash do
          requires :description, type: String, allow_blank: false,
                                 description: 'Brief description of API'
          requires :display_name, type: String, allow_blank: false,
                                  description: 'Displayed Name for the Developer Portal'
          requires :open_data, type: Boolean, allow_blank: false, default: false
          requires :va_internal_only, type: String,
                                      values: ['StrictlyInternal', 'AdditionalDetails', 'FlagOnly', ''],
                                      allow_blank: true
          requires :url_fragment, type: String, allow_blank: false,
                                  description: 'URL fragment'
          requires :overview_page_content, type: String, allow_blank: false,
                                           description: 'Markdown content for the "overview page" on DevPortal'
          requires :url_slug, type: String, allow_blank: false,
                              description: 'Url slug'
          requires :restricted_access_toggle, type: Boolean, allow_blank: false, default: false
          optional :restricted_access_details, type: String, allow_blank: true,
                                               description: 'Verbiage indicating why the API is restricted.'
          optional :block_sandbox_form, type: Boolean, allow_blank: false, default: false,
                                        description: 'Block Sandbox Access Form on dev portal.'
          requires :api_category_attributes, type: Hash do
            requires :id, type: Integer, values: ->(v) { ApiCategory.kept.map(&:id).include?(v) }
          end
          optional :oauth_info, type: Hash do
            optional :ccgInfo, type: Hash do
              optional :baseAuthPath, type: String, allow_blank: false
              optional :productionAud, type: String, allow_blank: true
              optional :productionWellKnownConfig, type: String, allow_blank: true
              optional :sandboxAud, type: String, allow_blank: true
              optional :sandboxWellKnownConfig, type: String, allow_blank: true
              optional :scopes, type: Array[String], allow_blank: false,
                                description: 'Scopes available<br /><h2>Comma separated!<h2>',
                                coerce_with: lambda { |v|
                                               v.split(',')
                                             }
            end
            optional :acgInfo, type: Hash do
              optional :baseAuthPath, type: String, allow_blank: false
              optional :productionWellKnownConfig, type: String, allow_blank: true
              optional :sandboxWellKnownConfig, type: String, allow_blank: true
              optional :productionAud, type: String, allow_blank: true
              optional :sandboxAud, type: String, allow_blank: true
              optional :scopes, type: Array[String], allow_blank: false,
                                description: 'Scopes available<br /><h2>Comma separated!<h2>',
                                coerce_with: lambda { |v|
                                  v.split(',')
                                }
            end
          end
          optional :veteran_redirect, type: Hash do
            optional :veteran_redirect_link_text, type: String, allow_blank: false
            optional :veteran_redirect_link_url, type: String, allow_blank: false
            optional :veteran_redirect_message, type: String, allow_blank: false
          end
        end
      end
      post '/' do
        validate_token(Scope.provider_write)

        api = Api.create(name: params.delete(:name))
        oauth_to_json if params[:api_metadatum_attributes][:oauth_info].present?
        api.update(params)

        present api, with: V0::Entities::ApiEntity
      end

      desc 'Provide list of apis within categories as developer-portal expects', deprecated: true
      params do
        optional :environment, type: String,
                               values: %w[sandbox production],
                               allow_blank: true
      end
      get '/transformations/legacy' do
        categories = {}
        ApiCategory.kept.order(:name).each do |category|
          categories[category.key] =
            V0::Entities::Legacy::ApiProviderCategoryEntity.represent(category, environment: params[:environment])
        end

        categories
      end

      resource ':providerName' do
        desc 'Get list of release notes'
        params do
          requires :providerName, type: String, allow_blank: false, description: 'Name of provider'
        end
        get '/release-notes' do
          release_notes = Api.find_by!(name: params[:providerName]).api_metadatum.api_release_notes.kept

          present release_notes.kept.order(date: :desc), with: V0::Entities::ApiReleaseNoteEntity
        end

        desc 'Publish release note to an active API provider **', {
          headers: {
            'Authorization' => {
              required: false
            }
          },
          detail: 'NOTE: Will discard existing release notes for provider and date'
        }
        params do
          requires :providerName, type: String, allow_blank: false, description: 'Name of provider'
          optional :date, type: Date, allow_blank: false, default: Time.zone.now.to_date.strftime('%Y-%m-%d')
          requires :content, type: String,
                             allow_blank: false,
                             coerce_with: lambda { |value|
                               value.start_with?('base64:') ? Base64.decode64(value.gsub(/^base64:/, '')) : value
                             }
        end
        post '/release-notes' do
          validate_token(Scope.provider_write)

          api_metadatum = Api.find_by!(name: params[:providerName]).api_metadatum
          existing_release_notes = ApiReleaseNote.where(api_metadatum_id: api_metadatum.id, date: params[:date]).kept
          existing_release_notes.discard_all if existing_release_notes.present?
          release_note = ApiReleaseNote.create(api_metadatum_id: api_metadatum.id,
                                               date: params[:date],
                                               content: params[:content])

          present release_note, with: V0::Entities::ApiReleaseNoteEntity, base_url: request.base_url
        end
      end
    end
  end
end
