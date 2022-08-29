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
        user = User.find_or_initialize_by(email: params[:email])
        create_internal_consumer(user) unless user.persisted?
        user
      end

      def create_internal_consumer(user)
        user.assign_attributes(first_name: params[:firstName], last_name: params[:lastName])
        user.save
        user.consumer = Consumer.create(description: 'Internal User', organization: 'Lighthouse')
      end

      def active_api?(api_name)
        Api.kept.filter { |a| a.api_metadatum.present? }.map(&:name).uniq.include?(api_name)
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
        raise 'Invalid API' unless active_api?(params[:providerName])

        api = Api.find_by(name: params[:providerName])
        present api, with: V0::Entities::ApiEntity
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

        namespace 'auth-types' do
          namespace 'apikey' do
            params do
              requires :providerName, type: String, allow_blank: false
              requires :firstName, type: String, allow_blank: false
              requires :lastName, type: String, allow_blank: false
              requires :email, type: String, allow_blank: false, regexp: /.+@.+/
              requires :termsOfService, type: Boolean, allow_blank: false, values: [true]
            end
            post '/consumers' do
              validate_token(Scope.consumer_write)

              raise 'Invalid API' unless active_api?(params[:providerName])

              api = Api.find_by(name: params[:providerName])
              user = initialize_user
              kong_consumer = Kong::ServiceFactory.service(:sandbox).third_party_signup(user, api)
              present user, with: V0::Entities::InternalConsumerEntity,
                            kong_consumer: kong_consumer,
                            api_name: api.name
            end
          end

          namespace 'oauth' do
            resource ':grantType' do
              params do
                requires :providerName, type: String, allow_blank: false
                requires :grantType, type: String, values: %w[acg ccg]
                requires :firstName, type: String, allow_blank: false
                requires :lastName, type: String, allow_blank: false
                requires :email, type: String, allow_blank: false, regexp: /.+@.+/
                requires :termsOfService, type: Boolean, allow_blank: false, values: [true]
                given grantType: ->(val) { val == 'acg' } do
                  requires :oAuthApplicationType, as: :application_type, type: String, values: %w[web native],
                                                  allow_blank: true
                  requires :oAuthRedirectURI, as: :redirect_uri, type: String,
                                              allow_blank: true,
                                              regexp: %r{^(https?://.+|)$},
                                              malicious_url_protection: true,
                                              coerce_with: ->(value) { value&.strip }
                end
                given grantType: ->(val) { val == 'ccg' } do
                  requires :oAuthPublicKey, as: :application_public_key, type: JSON
                end
              end
              post '/consumers' do
                validate_token(Scope.consumer_write)

                raise 'Invalid API' unless active_api?(params[:providerName])

                api = Api.find_by(name: params[:providerName])
                raise 'Invalid Grant Type' unless api.locate_auth_types.include?("oauth/#{params[:grantType]}")

                user = initialize_user
                okta_consumer = Okta::ServiceFactory.service(:sandbox)
                                                    .internal_consumer_signup(
                                                      user,
                                                      params[:grantType], api, declared(params)
                                                    )
                present user, with: V0::Entities::InternalConsumerEntity,
                              okta_consumer: okta_consumer,
                              api_name: api.name
              end
            end
          end
        end
      end
    end
  end
end
