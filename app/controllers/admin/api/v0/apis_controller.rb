# frozen_string_literal: true

require 'csv'

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

  def bulk_upload
    Api.upsert_all(apis_list.map do |api|
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
        updated_at: Time.zone.now,
        discarded_at: nil
      }
    end, unique_by: [:service_ref])

    if params[:authenticity_token].present?
      redirect_to admin_dashboard_path
    else
      render json: { data: 'apis_uploaded' }
    end
  end

  def destroy_all
    Api.discard_all

    redirect_to admin_dashboard_path
  end

  private

  def apis_list
    return params[:apis] if params[:apis].present?
    return [] if params[:apis].blank? && params[:file].blank?
    raise 'File not of type "text/csv"' unless params[:file].content_type == 'text/csv'

    file_content = CSV.parse(File.read(params[:file].tempfile), headers: true)
    file_content.map do |api|
      {
        'api' => {
          'name' => api['api_name'],
          'version' => api['version'].to_i,
          'auth_method' => api['auth_method'],
          'environment' => api['environment'],
          'open_api_url' => api['open_api_url'],
          'base_path' => api['base_path'],
          'service_ref' => api['service_ref'],
          'api_ref' => api['api_ref']
        }
      }
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
