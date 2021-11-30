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

  def apply
    @user = User.find_or_initialize_by(email: signup_params[:email])

    key_auth, _oauth = ApiService.new.fetch_auth_types signup_params[:apis]
    kong_consumer = generate_consumer_in_kong(key_auth) if key_auth.length.positive?
    prebuild_user = build_user_from_signup
    prebuild_user[:consumer_attributes][:sandbox_gateway_ref] = kong_consumer[:kong_id] if kong_consumer.present?
    @user.persisted? ? update_consumer(prebuild_user) : create_consumer(prebuild_user)

    return render json: { error: @user.errors.full_messages }, status: :unprocessable_entity unless @user.errors.empty?

    to_serialize = kong_consumer.presence ? kong_consumer : nil
    user_for_serializer = generate_serializable_user(to_serialize)

    render json: ConsumerApplySerializer.render(user_for_serializer)
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

  def signup_params
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

  def build_user_from_signup
    p = signup_params
    {
      email: p[:email],
      first_name: p[:firstName],
      last_name: p[:lastName],
      consumer_attributes: build_consumer_from_signup
    }
  end

  def build_consumer_from_signup
    p = signup_params
    {
      description: p[:description],
      organization: p[:organization],
      apis_list: p[:apis],
      tos_accepted: p[:termsOfService]
    }
  end

  def generate_serializable_user(to_merge)
    signup_params.to_h.merge(to_merge)
  end

  def generate_consumer_in_kong(key_auth)
    KongService.new.consumer_signup(signup_params, key_auth)
  end

  def update_consumer(params = user_params)
    @user.consumer.update(params[:consumer_attributes])
  end

  def create_consumer(params = user_params)
    @user.assign_attributes(params)
    @user.save
  end
end
