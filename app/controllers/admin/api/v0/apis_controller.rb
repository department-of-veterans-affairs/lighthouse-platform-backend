# frozen_string_literal: true

class Admin::Api::V0::ApisController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    api = Api.new api_params
    if api.save
      render json: api, serializer: ApiSerializer
    else
      render json: { error: api.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_params
    params.require(:api).permit(
      :name,
      :auth_method,
      :environment,
      :open_api_url,
      :base_path,
      :service_ref,
      :api_ref,
      :version
    )
  end
end
