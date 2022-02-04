# frozen_string_literal: true

require 'csv'

class Admin::ApisController < ApplicationController
  def bulk_upload
    apis_list.map do |api|
      api_built = {
        name: api.dig('api', 'name'),
        acl: api.dig('api', 'acl'),
        auth_server_access_key: api.dig('api', 'auth_server_access_key'),
        api_environments_attributes: {
          metadata_url: api.dig('api', 'metadata_url'),
          environments_attributes: {
            name: api.dig('api', 'env_name')
          }
        },
        api_ref_attributes: {
          name: api.dig('api', 'api_ref')
        },
        api_metadatum_attributes: {
          description: api.dig('api', 'api_description'),
          display_name: api.dig('api', 'display_name'),
          open_data: api.dig('api', 'open_data'),
          va_internal_only: api.dig('api', 'va_internal_only'),
          api_category_attributes: {
            name: api.dig('api', 'category', 'name')
          }
        }
      }
      manage_api api_built
    end

    if params[:authenticity_token].present?
      redirect_to admin_dashboard_index_path
    else
      render json: { data: 'apis_uploaded' }
    end
  end

  def destroy_all
    Api.discard_all

    redirect_to admin_dashboard_index_path
  end

  private

  def manage_api(manage_params)
    api = Api.find_or_create_by(name: manage_params[:name])
    if api.persisted?
      api.update manage_params
      api.undiscard
    else
      api.assign_attributes manage_params
    end

    api
  end

  def apis_list
    return params[:apis] if params[:apis].present?
    return [] if params[:apis].blank? && params[:file].blank?

    file_content = CSV.parse(File.read(params[:file].tempfile), headers: true)
    file_content.map do |api|
      restructure_api_data(api)
    end
  end

  def restructure_api_data(api)
    {
      'api' => {
        'name' => api['api_name'],
        'acl' => api['acl_ref'],
        'auth_server_access_key' => api['auth_server_access_key'],
        'metadata_url' => api['metadata_url'],
        'env_name' => api['environment'],
        'api_ref' => api['api_ref'],
        'api_description' => api['api_description'],
        'display_name' => api['display_name'],
        'open_data' => api['open_data'],
        'va_internal_only' => api['va_internal_only'],
        'category' => { 'name' api['category'] }
      }
    }
  end
end
