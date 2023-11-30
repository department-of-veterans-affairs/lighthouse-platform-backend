# frozen_string_literal: true

require 'digest'
require 'securerandom'
require 'validators/length'
require 'validators/malicious_url_protection'
require 'validators/consumer_has_sandbox_api'
require 'validators/provided_oauth_params'

module V0
  class Consumers < V0::Base
    version 'v0'

    helpers ApplicationHelper
    helpers ProductionRequestHelper
    helpers do
      def user_from_signup_params
        users = User.where('LOWER(email) = ?', params[:email].downcase.strip)
        user = users.present? ? users.first : User.new(email: params[:email].strip)

        user.first_name = params[:firstName]
        user.last_name = params[:lastName]
        user.consumer = Consumer.new if user.consumer.blank?
        user.consumer.description = params[:description]
        user.consumer.organization = params[:organization]
        user.consumer.apis_list = params[:apis]
        user.consumer.tos_accepted = params[:termsOfService]

        user
      end

      def send_production_access_emails(request)
        ProductionMailer.consumer_production_access(request).deliver_later
        ProductionMailer.support_production_access(request).deliver_later
      end

      def send_sandbox_welcome_emails(request, kong_consumer, okta_consumers, deeplink_url)
        SandboxMailer.consumer_sandbox_signup(request, kong_consumer, okta_consumers, deeplink_url).deliver_later
        if request[:apis].map(&:api_ref).map(&:name).include?('addressValidation')
          SandboxMailer.va_profile_sandbox_signup(request).deliver_later
        end
      end

      def slack_signup_options
        {
          first_name: params[:firstName],
          last_name: params[:lastName],
          description: params[:description],
          apis: params[:apis],
          email: params[:email],
          internal_api_info: {
            va_email: params.dig(:internalApiInfo, :vaEmail)
          }
        }
      end

      def okta_signup_options
        {
          application_type: params[:oAuthApplicationType],
          redirect_uri: params[:oAuthRedirectURI],
          application_public_key: params[:oAuthPublicKey]
        }
      end

      def sandbox_signup_event_content
        content = params.dup
        content[:apis] = params[:apis].map(&:api_ref).map(&:name).join(',')

        content
      end

      def subscribed?(consumers)
        consumers.filter { |c| c.unsubscribe != params[:subscribed] }
      end
    end

    resource 'consumers' do
      desc 'Lists all kept consumers', {
        headers: {
          'Authorization' => {
            required: false
          }
        }
      }
      params do
        optional :subscribed, type: Boolean
      end
      get '/' do
        validate_token(Scope.consumer_read)

        consumers = Consumer.kept

        consumers = subscribed?(consumers) unless params[:subscribed].nil?

        present consumers, with: V0::Entities::ConsumerEntity
      end

      desc 'Allows the updating of a consumer'
      params do
        requires :subscribed, type: Boolean, allow_blank: false
        requires :id, type: Integer, allow_blank: false
      end
      put '/:id' do
        validate_token(Scope.consumer_write)

        consumer = Consumer.find(params[:id])
        consumer.unsubscribe = !params[:subscribed]
        consumer.save!

        present consumer, with: V0::Entities::ConsumerEntity
      end

      desc 'Accept form submission from developer-portal', {
        deprecated: true,
        headers: {
          'X-Csrf-Token' => {
            required: false
          }
        }
      }
      params do
        requires :apis, type: Array[Api],
                        allow_blank: false,
                        coerce_with: ->(value) { ApiService.parse(value, filter_lpb: true) },
                        provided_oauth_params: true
        optional :description, type: String
        requires :email, type: String, allow_blank: false, regexp: /.+@.+/
        requires :firstName, type: String
        requires :lastName, type: String
        optional :oAuthApplicationType, type: String, values: %w[web native], allow_blank: true
        optional :oAuthRedirectURI, type: String,
                                    allow_blank: true,
                                    regexp: %r{^(https?://.+|)$},
                                    malicious_url_protection: true,
                                    coerce_with: ->(value) { value&.strip }
        optional :oAuthPublicKey, type: JSON
        optional :organization, type: String
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
        deeplink_hash = ''
        deeplink_url = ''
        if 'oauth/acg'.in? params[:apis].first.locate_auth_types
          url_slug = params[:apis].first.api_metadatum.url_slug
          deeplink_hash = generate_deeplink_hash(user)
          deeplink_url = generate_deeplink(url_slug, user)
        end

        kong_consumer = Kong::ServiceFactory.service(:sandbox).consumer_signup(user)
        okta_consumers = Okta::ServiceFactory.service(:sandbox).consumer_signup(user, okta_signup_options)
        Event.create(event_type: Event::EVENT_TYPES[:sandbox_signup], content: sandbox_signup_event_content)

        send_sandbox_welcome_emails(params, kong_consumer, okta_consumers, deeplink_url) if Flipper.enabled? :send_emails
        Slack::AlertService.new.send_slack_signup_alert(slack_signup_options) if Flipper.enabled? :send_slack_signup

        present user, with: V0::Entities::ConsumerApplicationEntity,
                      kong_consumer: kong_consumer,
                      okta_consumers: okta_consumers,
                      deeplink_hash: deeplink_hash
      end

      desc 'Accepts request for production access', {
        deprecated: true,
        headers: {
          'X-Csrf-Token' => {
            required: false
          }
        }
      }
      params do
        requires :apis, type: String, allow_blank: false
        optional :appDescription, type: String, length: 415
        optional :appName, type: String
        optional :breachManagementProcess, type: String
        optional :businessModel, type: String
        optional :centralizedBackendLog, type: String
        optional :distributingAPIKeysToCustomers, type: Boolean
        optional :exposeVeteranInformationToThirdParties, type: Boolean
        requires :is508Compliant, type: Boolean
        optional :listedOnMyHealthApplication, type: Boolean
        optional :logoLarge, type: String
        optional :logoIcon, type: String
        optional :monitizationExplanation, type: String
        requires :monitizedVeteranInformation, type: Boolean
        optional :multipleReqSafeguards, type: String
        optional :namingConvention, type: String
        optional :oAuthApplicationType, type: String, values: %w[web native], allow_blank: false
        optional :oAuthRedirectURI, type: String,
                                    allow_blank: false,
                                    regexp: %r{^(https?://.+|)$},
                                    malicious_url_protection: true,
                                    coerce_with: ->(value) { value&.strip }
        optional :oAuthPublicKey, type: JSON
        requires :organization, type: String
        optional :phoneNumber,
                 regexp: { value: /
                            ^(?:\([2-9]\d{2}\)\ ?|[2-9]\d{2}(?:-?|\ ?|\.?))
                            [2-9]\d{2}[- .]?\d{4}((\ )?(\()
                            ?(ext|x|extension)([- .:])?\d{1,6}(\))?)?$
                          /x,
                           message: '"phoneNumber" failed custom validation because phone number format invalid. ' \
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
        optional :vulnerabilityManagement, type: String
        optional :website, type: String

        all_or_none_of :oAuthApplicationType, :oAuthRedirectURI
      end
      post 'production-requests' do
        header 'Access-Control-Allow-Origin', request.host_with_port
        protect_from_forgery

        begin
          create_production_request_record!(params: params)
        rescue
          # just in-case... don't want to disrupt the existing workflow
        end
        send_production_access_emails(params) if Flipper.enabled? :send_emails

        body false
      end

      desc 'Peruses Elasticsearch for a successful consumer first-call (via oauth and/or key-auth)', {
        headers: {
          'Authorization' => {
            required: false
          }
        }
      }
      params do
        requires :consumerId, type: String, allow_blank: false,
                              description: 'Consumer ID from Lighthouse Platform Backend'
      end
      get '/:consumerId/statistics' do
        validate_token(Scope.consumer_read)

        consumer = Consumer.find(params[:consumerId])
        first_call = ElasticsearchService.new.first_successful_call consumer
        present first_call, with: V0::Entities::ConsumerStatisticEntity
      end

      desc 'Promotes a consumer to the production environment for the provided API(s)', {
        headers: {
          'Authorization' => {
            required: false
          }
        }
      }
      params do
        requires :apis, type: Array[Api],
                        allow_blank: false,
                        description: 'Comma separated values of API Refs for promotion to production',
                        consumer_has_sandbox_api: true,
                        coerce_with: ->(value) { ApiService.parse(value, filter_lpb: false) }
        optional :oAuthApplicationType, type: String, values: %w[web native], allow_blank: false
        optional :oAuthRedirectURI, type: String,
                                    allow_blank: false,
                                    regexp: %r{^https?://.+},
                                    malicious_url_protection: true
        optional :oAuthPublicKey, type: JSON
      end
      post '/:consumerId/promotion-requests' do
        validate_token(Scope.consumer_write)

        user = Consumer.find(params[:consumerId]).user
        params[:apis].map { |api| user.consumer.promote_to_prod(api.api_ref.name) }

        user.consumer.apis_list = params[:apis]
        kong_consumer = Kong::ServiceFactory.service(:production).consumer_signup(user)
        okta_consumers = Okta::ServiceFactory.service(:production).consumer_signup(user, okta_signup_options)

        present user, with: V0::Entities::ConsumerApplicationEntity,
                      kong_consumer: kong_consumer,
                      okta_consumers: okta_consumers
      end

      desc 'Returns the required Sigv4 policy to permit logo uploads in the production request form', {
        headers: {
          'Authorization' => {
            required: false
          }
        }
      }
      params do
        requires :fileName, type: String, allow_blank: false
        requires :fileType,
                 regexp: { value: %r{^image/(jpeg|png)$},
                           message: 'Files must be one of these types: image/jpeg, image/png' }
      end
      post 'logo-upload' do
        header 'Access-Control-Allow-Origin', request.host_with_port
        protect_from_forgery

        aws = AwsSigv4Service.new
        aws.set_key("#{SecureRandom.uuid}/#{params[:fileName]}")
        aws.set_content_type(params[:fileType])
        signed_request = aws.sign_request

        present signed_request, with: V0::Entities::AwsSigv4UploadEntity
      end
    end
  end
end
