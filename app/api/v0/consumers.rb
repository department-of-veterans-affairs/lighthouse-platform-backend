# frozen_string_literal: true

require 'validators/length'
require 'validators/malicious_url_protection'

module V0
  class Consumers < V0::Base
    version 'v0'

    helpers do
      def user_from_signup_params
        user = User.find_or_initialize_by(email: params[:email])

        user.first_name = params[:firstName]
        user.last_name = params[:lastName]
        user.consumer = Consumer.new if user.consumer.blank?
        user.consumer.description = params[:description]
        user.consumer.organization = params[:organization]
        user.consumer.apis_list = params[:apis]
        user.consumer.tos_accepted = params[:termsOfService]

        user
      end

      def kong_signup(user, key_auth, environment = nil)
        kong_service = environment.eql?(:production) ? Kong::ProductionService : Kong::SandboxService
        kong_consumer = kong_service.new.consumer_signup(user, key_auth)

        user.consumer.sandbox_gateway_ref = kong_consumer[:kong_id] if environment.nil?
        user.consumer.prod_gateway_ref = kong_consumer[:kong_id] if environment.present?

        [user, kong_consumer]
      end

      def okta_signup(user, oauth, environment = nil)
        okta_service = environment.eql?(:production) ? Okta::ProductionService : Okta::SandboxService
        okta_consumer = okta_service.new.consumer_signup(user,
                                                         oauth,
                                                         application_type: params[:oAuthApplicationType],
                                                         redirect_uri: params[:oAuthRedirectURI])
        user.consumer.sandbox_oauth_ref = okta_consumer[:id] if environment.nil?
        user.consumer.prod_oauth_ref = okta_consumer[:id] if environment.present?

        [user, okta_consumer]
      end

      def missing_oauth_params_exception
        Grape::Exceptions::Validation.new(params: %w[oAuthApplicationType oAuthRedirectURI],
                                          message: 'missing one or more oAuth values')
      end

      def missing_oauth_params?
        params[:oAuthApplicationType].blank? || params[:oAuthRedirectURI].blank?
      end

      def send_production_access_emails(request)
        ProductionMailer.consumer_production_access(request).deliver_later
        ProductionMailer.support_production_access(request).deliver_later
      end

      def send_sandbox_welcome_emails(request, kong_consumer, okta_consumer)
        SandboxMailer.consumer_sandbox_signup(request, kong_consumer, okta_consumer).deliver_later
        if request[:apis].split(',').include?('addressValidation')
          SandboxMailer.va_profile_sandbox_signup(request).deliver_later
        end
      end

      def promote_consumer(user, apis_list)
        key_auth, oauth = ApiService.new.fetch_auth_types apis_list

        _user, kong_consumer = kong_signup(user, key_auth, :production) if key_auth.present?
        _user, okta_consumer = okta_signup(user, oauth, :production) if oauth.present?
        [kong_consumer, okta_consumer]
      end

      def validate_refs(consumer_api_refs)
        [].tap do |ref|
          params[:apis].split(',').map do |api_ref|
            ref << api_ref if consumer_api_refs.include?(api_ref)
          end
        end
      end

      def send_slack_signup_alert
        Slack::AlertService.new.alert_slack(Figaro.env.slack_signup_channel,
                                            slack_success_message(slack_signup_message))
      end

      def slack_signup_message
        [
          "#{params[:firstName]}, #{params[:lastName]}: #{slack_email_list}",
          "Description: #{params[:description]}",
          'Requested access to:',
          map_apis(params[:apis]).to_s
        ].join(" \n")
      end

      def map_apis(apis)
        apis.split(',').map { |api| "* #{api}" }.join("\n")
      end

      def include_va_email?
        params[:internalApiInfo][:vaEmail].present? if params[:internalApiInfo]
      end

      def slack_email_list
        "Contact Email: #{params[:email]}"\
          "#{include_va_email? ? " | VA Email: #{params[:internalApiInfo][:vaEmail]}" : ''}"
      end

      def slack_success_message(message)
        {
          attachments: [
            {
              color: 'good',
              fallback: message,
              text: message,
              title: 'New User Application'
            }
          ]
        }
      end
    end

    resource 'consumers' do
      desc 'Lists all kept consumers'
      get '/' do
        consumers = Consumer.kept

        present consumers, with: V0::Entities::ConsumerEntity
      end

      desc 'Accept form submission from developer-portal', {
        deprecated: true,
        headers: {
          'X-Csrf-Token' => {
            required: true
          }
        }
      }
      params do
        requires :apis, type: String, allow_blank: false
        optional :description, type: String
        requires :email, type: String, allow_blank: false, regexp: /.+@.+/
        requires :firstName, type: String
        requires :lastName, type: String
        optional :oAuthApplicationType, type: String, values: %w[web native], allow_blank: true
        optional :oAuthRedirectURI, type: String,
                                    allow_blank: true,
                                    regexp: %r{^(https?://.+|)$},
                                    malicious_url_protection: true
        requires :organization, type: String
        requires :termsOfService, type: Boolean, allow_blank: false, values: [true]
        optional :internalApiInfo, type: Hash do
          optional :programName, type: String
          optional :sponsorEmail, type: String
          optional :vaEmail, type: String
        end

        all_or_none_of :oAuthApplicationType, :oAuthRedirectURI
      end
      post 'applications' do
        header 'Access-Control-Allow-Origin', request.host_with_port
        protect_from_forgery

        user = user_from_signup_params

        key_auth, oauth = ApiService.new.fetch_auth_types user.consumer.apis_list
        raise missing_oauth_params_exception if oauth.any? && missing_oauth_params?

        user, kong_consumer = kong_signup(user, key_auth) if key_auth.present?
        user, okta_consumer = okta_signup(user, oauth) if oauth.present?
        user.save!
        user.undiscard if user.discarded?
        Event.create(event_type: Event::EVENT_TYPES[:sandbox_signup], content: params)

        send_sandbox_welcome_emails(params, kong_consumer, okta_consumer) if Flipper.enabled? :send_emails
        send_slack_signup_alert if Flipper.enabled? :send_slack_signup

        present user, with: V0::Entities::ConsumerApplicationEntity, kong: kong_consumer, okta: okta_consumer
      end

      desc 'Accepts request for production access', {
        deprecated: true,
        headers: {
          'X-Csrf-Token' => {
            required: true
          }
        }
      }
      params do
        requires :apis, type: String, allow_blank: false
        optional :appDescription, type: String
        optional :appName, type: String
        optional :breachManagementProcess, type: String
        optional :businessModel, type: String
        optional :centralizedBackendLog, type: String
        optional :distributingAPIKeysToCustomers, type: Boolean
        optional :exposeVeteranInformationToThirdParties, type: Boolean
        requires :is508Compliant, type: Boolean
        optional :listedOnMyHealthApplication, type: Boolean
        optional :monitizationExplanation, type: String
        requires :monitizedVeteranInformation, type: Boolean
        optional :multipleReqSafeguards, type: String
        optional :namingConvention, type: String
        requires :organization, type: String
        optional :phoneNumber,
                 regexp: { value: /
                            ^(?:\([2-9]\d{2}\)\ ?|[2-9]\d{2}(?:-?|\ ?|\.?))
                            [2-9]\d{2}[- .]?\d{4}((\ )?(\()
                            ?(ext|x|extension)([- .:])?\d{1,6}(\))?)?$
                          /x,
                           message: '"phoneNumber" failed custom validation because phone number format invalid. '\
                                    'Valid format examples: 222-333-4444, (222) 333-4444, 2223334444' }
        optional :piiStorageMethod, type: String
        optional :platforms, type: String
        optional :policyDocuments, type: Array[String]
        requires :primaryContact, type: Hash do
          requires :email, type: String, regexp: /^(?!.*(test|sample|fake|email)).*/
          requires :firstName, type: String
          requires :lastName, type: String
        end
        optional :productionKeyCredentialStorage, type: String
        optional :productionOrOAuthKeyCredentialStorage, type: String
        optional :scopesAccessRequested, type: String
        requires :secondaryContact, type: Hash do
          requires :email, type: String, regexp: /^(?!.*(test|sample|fake|email)).*/
          requires :firstName, type: String
          requires :lastName, type: String
        end
        optional :signUpLink, type: Array[String]
        requires :statusUpdateEmails, type: Array[String], regexp: /^(?!.*(test|sample|fake|email)).*/
        requires :storePIIOrPHI, type: Boolean
        optional :supportLink, type: Array[String]
        optional :thirdPartyInfoDescription, type: String
        requires :valueProvided, type: String
        optional :vasiSystemName, type: String
        requires :veteranFacing, type: Boolean
        optional :veteranFacingDescription, type: String, length: 415
        optional :vulnerabilityManagement, type: String
        optional :website, type: String
      end
      post 'production-requests' do
        header 'Access-Control-Allow-Origin', request.host_with_port
        protect_from_forgery

        send_production_access_emails(params) if Flipper.enabled? :send_emails

        body false
      end

      desc 'Peruses Elasticsearch for a successful consumer first-call (via oauth and/or key-auth)'
      get '/:consumerId/statistics' do
        params do
          requires :consumerId, type: String, allow_blank: false,
                                description: 'Consumer ID from Lighthouse Consumer Management Service'
        end
        consumer = Consumer.find(params[:consumerId])
        first_call = ElasticsearchService.new.first_successful_call consumer
        present first_call, with: V0::Entities::ConsumerStatisticEntity
      end

      desc 'Promotes a consumer to the production environment for the provided API(s)'
      post '/:consumerId/promotion-requests' do
        params do
          requires :apis, type: String, allow_blank: false,
                          description: 'Comma separated values of API Refs for promotion to production'
          optional :oAuthApplicationType, type: String, values: %w[web native], allow_blank: false
          optional :oAuthRedirectURI, type: String,
                                      allow_blank: false,
                                      regexp: %r{^https?://.+},
                                      malicious_url_protection: true
        end
        status 200
        consumer = Consumer.find(params[:consumerId])
        consumer_api_refs = consumer.apis.map(&:api_ref).map(&:name)

        api_refs = validate_refs(consumer_api_refs)
        raise ApiValidationError if api_refs.empty?

        begin
          api_refs.map { |api_ref| consumer.promote_to_prod(api_ref) }
        rescue
          raise ApiValidationError
        end
        kong_consumer, okta_consumer = promote_consumer(consumer.user, params[:apis])
        consumer.user.save!

        present consumer.user, with: V0::Entities::ConsumerApplicationEntity, kong: kong_consumer, okta: okta_consumer
      end
    end
  end
end
