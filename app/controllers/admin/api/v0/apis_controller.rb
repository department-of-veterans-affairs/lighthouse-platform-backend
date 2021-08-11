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

  # rubocop:disableMetrics/MethodLength
  def bulk_upload
    Api.upsert_all(params[:apis].map do |api|
      {
        name:	api.dig('api', 'name'),
        version: api.dig('api', 'version'),
        auth_method: api.dig('api', 'auth_method'),
        environment: api.dig('api', 'environment'),
        open_api_url: api.dig('api', 'open_api_url'),
        base_path: api.dig('api', 'base_path'),
        api_ref: api.dig('api', 'api_ref'),
        service_ref: api.dig('api', 'service_ref'),
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }
    end, unique_by: [:service_ref])
    render json: { data: 'apis_uploaded' }
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
