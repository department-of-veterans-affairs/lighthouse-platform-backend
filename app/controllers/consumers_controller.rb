# frozen_string_literal: true

class ConsumersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @user = User.find_or_initialize_by(email: params[:user][:email])
    if @user.persisted? && @user.consumer.present?
      update_consumer
    else
      create_consumer
    end
    return render json: { error: @user.errors.full_messages }, status: :unprocessable_entity unless @user.errors.empty?

    render json: UserSerializer.render(@user)
  end

  #
  # Submission from developer-portal form to sign up for sandbox api access.
  #
  def apply
    user = user_from_signup_params

    key_auth, oauth = ApiService.new.fetch_auth_types user.consumer.apis_list
    raise missing_oauth_params_exception if oauth.any? && missing_oauth_params?

    kong_consumer = KongService.new.consumer_signup(user, key_auth) unless key_auth.empty?
    user.consumer.sandbox_gateway_ref = kong_consumer[:kong_id]

    unless oauth.empty?
      okta_consumer = OktaService.new.consumer_signup(user,
                                                      oauth,
                                                      application_type: signup_params[:oAuthApplicationType],
                                                      redirect_uri: signup_params[:oAuthRedirectURI])
      user.consumer.sandbox_oauth_ref = okta_consumer.id
    end

    user.save!
    user.undiscard if user.discarded?

    render json: ConsumerApplySerializer.render(user, kong: kong_consumer, okta: okta_consumer)
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      consumer_attributes: %i[
        description
        organization
        sandbox_gateway_ref
        sandbox_oauth_ref
        prod_gateway_ref
        prod_oauth_ref
        apis_list
        tos_accepted
      ]
    )
  end

  def user_from_signup_params
    user = User.find_or_initialize_by(email: signup_params[:email])

    user.first_name = signup_params[:firstName]
    user.last_name = signup_params[:lastName]
    user.consumer = Consumer.new if user.consumer.blank?
    user.consumer.description = signup_params[:description]
    user.consumer.organization = signup_params[:organization]
    user.consumer.apis_list = signup_params[:apis]
    user.consumer.tos_accepted = signup_params[:termsOfService]

    user
  end

  def missing_oauth_params_exception
    return ActionController::ParameterMissing.new('oAuthApplicationType') if params[:oAuthApplicationType].blank?

    ActionController::ParameterMissing.new('oAuthRedirectURI')
  end

  def missing_oauth_params?
    params[:oAuthApplicationType].blank? || params[:oAuthRedirectURI].blank?
  end

  def signup_params
    unless oauth_application_type_valid?
      message = "Invalid value for oAuthApplicationType: #{params[:oAuthApplicationType]}"
      raise ActionController::ParameterMissing, message
    end

    params.permit(
      :apis,
      :description,
      :email,
      :firstName,
      :lastName,
      :oAuthApplicationType,
      :oAuthRedirectURI,
      :organization,
      :termsOfService
    )
  end

  def oauth_application_type_valid?
    return true if params[:oAuthApplicationType].blank?

    %w[web native].include?(params[:oAuthApplicationType])
  end

  def update_consumer(params = user_params)
    @user.consumer.update(params[:consumer_attributes])
  end

  def create_consumer(params = user_params)
    @user.assign_attributes(params)
    @user.save
  end
end
