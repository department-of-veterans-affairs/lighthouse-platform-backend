# frozen_string_literal: true

class ConsumersController < ApplicationController
  def create
    @user = User.create(user_params)
    if @user.save
      @consumer = Consumer.create(consumer_params)
      if @consumer.save
        puts @consumer
      else
        render json: { error: @consumer.errors.full_messages }, status: :ok
      end
    else
      render json: { error: @user.errors.full_messages }, status: :ok
    end
  end

  private

  def user_params
    params.require(:user).permit(
                                  :email,
                                  :first_name,
                                  :last_name,
                                  :organization,
                                  :role
                                )
  end

  def consumer_params
    params.require(:consumer).permit(
      :description,
      :tos_accepted
    )
  end

  def generate_user_params(params)
    user_params = Hash.new
    user_params[:email_address] = params.delete :email
    user_params[:first_name] = params.delete :firstName
    user_params[:last_name] = params.delete :lastName
    user_params[:organization] = params.delete :organization
    return user_params
  end
end
