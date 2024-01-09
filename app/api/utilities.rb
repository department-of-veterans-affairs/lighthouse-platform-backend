# frozen_string_literal: true

require 'rake'
require 'net/http'
require 'uri'

class Utilities < Base
  helpers do
    def user_from_signup_params
      user = User.find_or_initialize_by(email: params[:email])

      user.first_name = params[:firstName]
      user.last_name = params[:lastName]
      user.consumer = Consumer.new if user.consumer.blank?
      user.consumer.description = params[:description]
      user.consumer.organization = params[:organization]
      user.consumer.apis_list = ApiService.parse('ccg/lpb', filter_lpb: false)
      user.consumer.tos_accepted = params[:termsOfService]

      user
    end

    def okta_signup_options
      { application_public_key: params[:oAuthPublicKey] }
    end
  end

  resource 'utilities' do
    resource 'consumers' do
      desc 'Returns list of consumers'
      params do
        optional :apiId, type: Integer, description: 'Id of API to filter for'
        optional :environment, type: String, description: 'Environment to filter for', values: %w[sandbox production]
        all_or_none_of :apiId, :environment
      end
      get '/' do
        # no filters provided, return all consumers
        unless params[:apiId] && params[:environment]
          users = User.kept.select { |user| user.consumer.present? }
          return present users, with: Entities::UserEntity
        end

        api_id_filter = params[:apiId]
        environment_filter = params[:environment]

        api = Api.find(api_id_filter)
        environment = Environment.find_by(name: environment_filter)
        api_environment = ApiEnvironment.find_by(environment: environment, api: api)

        users = api_environment.consumer_api_assignment.map do |record|
          record.consumer.user.kept? ? record.consumer.user : nil
        end.compact

        present users, with: Entities::UserEntity
      end

      desc 'Returns last week signups report'
      namespace '/signups-report' do
        get '/week' do
          Slack::ReportService.new.query_events('week', 1.week.ago)
        end
        get '/month' do
          Slack::ReportService.new.query_events('month', 1.month.ago)
        end
      end
    end

    resource 'apis' do
      desc 'Return list of APIs'
      get '/' do
        apis = Api.left_joins(:api_ref).kept

        present apis, with: Entities::ApiEntity
      end

      desc 'Returns a list of API categories'
      get '/categories' do
        api_categories = ApiCategory.kept

        present api_categories, with: Entities::ApiCategoryEntity
      end
    end

    resource 'kong' do
      desc 'Return list Kong consumers'
      get '/consumers' do
        Kong::SandboxService.new.list_all_consumers
      end

      desc 'Return list Kong consumers not in LPB'
      params do
        requires :environment, type: String, allow_blank: false, values: %w[sandbox production], default: 'sandbox'
        optional :filterLastDay, type: Boolean, allow_blank: false, values: [true, false], default: true
      end
      get '/environments/:environment/unknown-consumers' do
        drift_service_arg = params[:environment] == 'production' ? :production : nil
        Kong::DriftService.new(drift_service_arg).detect_drift(alert: false, filter: params[:filterLastDay])
      end
    end

    resource 'okta' do
      desc 'Return list Okta applications not in LPB'
      params do
        requires :environment, type: String, allow_blank: false, values: %w[sandbox production], default: 'sandbox'
        optional :filterLastDay, type: Boolean, allow_blank: false, values: [true, false], default: true
      end
      get '/environments/:environment/unknown-applications' do
        drift_service_arg = params[:environment] == 'production' ? :production : nil
        Okta::DriftService.new(drift_service_arg).detect_drift(alert: false, filter: params[:filterLastDay])
      end

      namespace 'lpb' do
        params do
          requires :environment, type: Symbol, values: [:production], allow_blank: false
          optional :description, type: String
          requires :email, type: String, allow_blank: false, regexp: /.+@.+/
          requires :firstName, type: String
          requires :lastName, type: String
          optional :oAuthPublicKey, type: JSON
          requires :organization, type: String
          requires :termsOfService, type: Boolean, allow_blank: false, values: [true]
        end
        post 'applications' do
          user = user_from_signup_params

          okta_service = Okta::ServiceFactory.service(params[:environment])
          okta_consumers = okta_service.consumer_signup(user, okta_signup_options)
          Event.create(event_type: Event::EVENT_TYPES[:lpb_signup], content: { user: user, okta: okta_consumers })

          present user, with: V0::Entities::ConsumerApplicationEntity,
                        okta_consumers: okta_consumers
        end
      end
    end

    resource 'address-validation' do
      desc 'Returns result from Address Validation API v2 /candidate endpoint'
      params do
        requires :requestAddress, type: Hash do
          requires :addressLine1, type: String
          optional :addressLine2, type: String
          optional :addressLine3, type: String
          requires :city, type: String
          requires :zipCode5, type: String
          optional :zipCode4, type: String
          requires :internationalPostalCode, type: String
          requires :addressPOU, type: String
          requires :stateProvince, type: Hash do
            requires :name, type: String
            requires :code, type: String
          end
          requires :requestCountry, type: Hash do
            requires :countryName, type: String
            requires :countryCode, type: String
          end
        end
      end
      post '/candidate' do
        header 'Access-Control-Allow-Origin', request.host_with_port
        protect_from_forgery

        uri = URI.parse(ENV.fetch('ADDRESS_VALIDATION_API_V2_CANDIDATE_ENDPOINT'))
        http = Net::HTTP.new(uri)
        headers = {
          'apikey' => ENV.fetch(Figaro.env.address_validation_api_v2_apikey),
          'Content-Type' => 'application/json'
        }
        request = Net::HTTP::Post.new(uri.path, headers)
        request.body = params.require(:requestAddress).permit(
          :addressLine1, :addressLine2, :addressLine3, :city, :zipCode5, :zipCode4, 
          :internationalPostalCode, :addressPOU, stateProvince: [:name, :code],
          requestCountry: [:countryName, :countryCode]
        ).to_json
        response = http.request(request)

        render json: response.body
      end
    end
  end
end
