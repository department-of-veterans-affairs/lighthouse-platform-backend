# frozen_string_literal: true

class ConsumersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      render json: { user_created: @user }, status: :ok
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :organization,
      consumer_attributes: [
        :description,
        :sandbox_gateway_ref,
        :sandbox_oauth_ref,
        :prod_gateway_ref,
        :prod_oauth_ref,
        :apis_list
      ]
    )
  end
end
