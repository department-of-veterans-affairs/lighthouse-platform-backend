# frozen_string_literal: true

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

      def raise_missing_oauth_params_exception
        raise Grape::Exceptions::Validation, message: 'missing one or more oAuth values'
      end

      def missing_oauth_params?
        params[:oAuthApplicationType].blank? || params[:oAuthRedirectURI].blank?
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
        raise_missing_oauth_params_exception if oauth.any? && missing_oauth_params?

        user, kong_consumer = kong_signup(user, key_auth) if key_auth.present?
        user, okta_consumer = okta_signup(user, oauth) if oauth.present?
        user.save!
        user.undiscard if user.discarded?

        present user, with: V0::Entities::ConsumerApplicationEntity, kong: kong_consumer, okta: okta_consumer
      end
    end
  end
end
