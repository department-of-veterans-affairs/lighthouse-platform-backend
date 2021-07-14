# frozen_string_literal: true

class DeveloperApplicationController < ApplicationController
  def apply
    body = request_params
    user_params = convert_request(body)

    @user = User.create(user_params)
    if @user.save
      @user
    else
      puts @user.errors.full_messages
    end
  end

  private

  def request_params
    params.permit(:email,
                  :firstName,
                  :lastName,
                  :organization,
                  :description,
                  :apis,
                  :oAuthApplicationType,
                  :oAuthRedirectURI,
                  :termsOfService
                )
  end

  def convert_request(params)
    user_params = Hash.new
    user_params[:email_address] = params.delete :email
    user_params[:first_name] = params.delete :firstName
    user_params[:last_name] = params.delete :lastName
    user_params[:organization] = params.delete :organization
    return user_params
  end
end
