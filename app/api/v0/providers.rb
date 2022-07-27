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

      def filter_oauth_type(apis, auth_type)
        apis.select do |api|
          check_env = ["#{api.auth_server_access_key}_#{auth_type}"]
          check_env << api.auth_server_access_key if auth_type == 'acg'
          check_env.any? { |env_var| Figaro.env.send(env_var).present? }
        end
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
        optional :auth_type, type: String, values: %w[apikey oauth oauth/acg oauth/ccg]
      end
      get '/' do
        validate_token(Scope.provider_read)

        apis = Api

        if params[:auth_type].present?
          auth_types = params[:auth_type].split('/')
          apis = Api.auth_type(auth_types.first)
        end

        apis = apis.kept if params[:status] == 'active'
        apis = apis.discarded if params[:status] == 'inactive'
        apis = apis.displayable
        apis = apis.order(:name)
        apis = filter_oauth_type(apis, auth_types.second) if params[:auth_type].present? && auth_types.length > 1

        present apis, with: V0::Entities::ApiEntity
      end

      params do
        requires :name, type: String, allow_blank: false, description: 'Name of API Provider'
        requires :api_environments_attributes, type: Hash do
          requires :metadata_url, type: String, allow_blank: false,
                                  description: 'Metadata URL typically served by Docserver'
          requires :environments_attributes, type: Hash do
            requires :name, type: Array[String], allow_blank: false,
                            description: 'Environments API is available within - comma separated',
                            values: ->(v) { %w[sandbox production].include?(v) },
                            coerce_with: ->(v) { v.split(',') }
          end
        end
        optional :acl, type: String, allow_blank: false, description: 'Kong ACL for the API'
        optional :auth_server_access_key, type: String, allow_blank: false,
                                          description: 'ID for the associated Okta Auth Server'
        requires :api_ref_attributes, type: Hash do
          requires :name, type: String, allow_blank: false,
                          description: 'Reference name for developer portal'
        end
        requires :api_metadatum_attributes, type: Hash do
          requires :description, type: String, allow_blank: false,
                                 description: 'Brief description of API'
          requires :display_name, type: String, allow_blank: false,
                                  description: 'Displayed Name for the Developer Portal'
          requires :open_data, type: Boolean, allow_blank: false, default: false
          requires :va_internal_only, type: String,
                                      values: %w[StrictlyInternal AdditionalDetails FlagOnly],
                                      allow_blank: true
          requires :url_fragment, type: String, allow_blank: false,
                                  description: 'URL fragment'
          optional :oauth_info, type: Hash do
            optional :ccgInfo, type: Hash do
              optional :baseAuthPath, type: String, allow_blank: false
              optional :productionAud, type: String, allow_blank: true
              optional :sandboxAud, type: String, allow_blank: true
              optional :scopes, type: Array[String], allow_blank: false,
                                description: 'Scopes available - comma separated',
                                coerce_with: lambda { |v|
                                               v.split(',')
                                             }
            end
            optional :acgInfo, type: Hash do
              optional :baseAuthPath, type: String, allow_blank: false
              optional :scopes, type: Array[String], allow_blank: false,
                                description: 'Scopes available - comma separated',
                                coerce_with: lambda { |v|
                                  v.split(',')
                                }
            end
          end
          requires :api_category_attributes, type: Hash do
            requires :id, type: Integer, values: ->(v) { ApiCategory.kept.map(&:id).include?(v) }
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
                               values: %w[dev staging sandbox production],
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
        desc 'Get list of release notes', {
          headers: {
            'Authorization' => {
              required: false
            }
          }
        }
        params do
          requires :providerName, type: String, allow_blank: false, description: 'Name of provider'
        end
        get '/release-notes' do
          validate_token(Scope.provider_read)

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
          requires :content, type: String, allow_blank: false
        end
        post '/release-notes' do
          validate_token(Scope.provider_write)

          api_metadatum = Api.kept.find_by!(name: params[:providerName]).api_metadatum
          existing_release_notes = ApiReleaseNote.where(api_metadatum_id: api_metadatum.id, date: params[:date]).kept
          existing_release_notes.discard_all if existing_release_notes.present?
          release_note = ApiReleaseNote.create(api_metadatum_id: api_metadatum.id,
                                               date: params[:date],
                                               content: CGI.unescape(params[:content]))

          present release_note, with: V0::Entities::ApiReleaseNoteEntity, base_url: request.base_url
        end
      end
    end
  end
end
