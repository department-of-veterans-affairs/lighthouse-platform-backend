# frozen_string_literal: true

module V0
  class Consumers < V0::Base
    require_relative '../validators/length'
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

      def kong_signup(user, key_auth)
        kong_consumer = KongService.new.consumer_signup(user, key_auth)
        user.consumer.sandbox_gateway_ref = kong_consumer[:kong_id]

        [user, kong_consumer]
      end

      def okta_signup(user, oauth)
        okta_consumer = OktaService.new.consumer_signup(user,
                                                        oauth,
                                                        application_type: params[:oAuthApplicationType],
                                                        redirect_uri: params[:oAuthRedirectURI])
        user.consumer.sandbox_oauth_ref = okta_consumer.id

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
    end

    resource 'consumers' do
      desc 'Accept form submission from developer-portal'
      params do
        requires :apis, type: String, allow_blank: false
        requires :description, type: String
        requires :email, type: String, allow_blank: false, regexp: /.+@.+/
        requires :firstName, type: String
        requires :lastName, type: String
        optional :oAuthApplicationType, type: String, values: %w[web native], allow_blank: false
        optional :oAuthRedirectURI, type: String, allow_blank: false, regexp: %r{^https?://.+}
        requires :organization, type: String
        requires :termsOfService, type: Boolean, allow_blank: false

        all_or_none_of :oAuthApplicationType, :oAuthRedirectURI
      end
      post 'applications' do
        user = user_from_signup_params

        key_auth, oauth = ApiService.new.fetch_auth_types user.consumer.apis_list
        raise missing_oauth_params_exception if oauth.any? && missing_oauth_params?

        user, kong_consumer = kong_signup(user, key_auth) if key_auth.present?
        user, okta_consumer = okta_signup(user, oauth) if oauth.present?
        user.save!
        user.undiscard if user.discarded?

        present user, with: V0::Entities::ConsumerApplicationEntity, kong: kong_consumer, okta: okta_consumer
      end

      desc 'Accepts request for production access'
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

      post 'production_request' do
        status 200
        send_production_access_emails(params)

        present {}
      end
    end
  end
end
