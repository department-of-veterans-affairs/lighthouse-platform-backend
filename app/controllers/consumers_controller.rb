# frozen_string_literal: true

class ConsumersController < ApplicationController
  def create
    @options = {}
    @options[:include] = [:consumer]
    @user = User.find_or_initialize_by(email: params[:user][:email])
    if @user.persisted? && @user.consumer.present?
      update_consumer
    else
      create_consumer
    end
    return render json: { error: @user.errors.full_messages }, status: :unprocessable_entity unless @user.errors.empty?

    render json: serialize_user
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :organization,
      consumer_attributes: %i[
        description
        sandbox_gateway_ref
        sandbox_oauth_ref
        prod_gateway_ref
        prod_oauth_ref
        apis_list
        tos_accepted
      ]
    )
  end

  def update_consumer
    @user.consumer.update(user_params[:consumer_attributes])
  end

  def create_consumer
    @user.assign_attributes(user_params)
    @user.save
  end

  def serialize_user
    UserSerializer.new(@user, @options).serializable_hash.to_json
  end
end
