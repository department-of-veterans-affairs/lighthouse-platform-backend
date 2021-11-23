# frozen_string_literal: true

require 'csv'

class Admin::Api::V0::ApisController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    api = manage_api api_params
    if api.save
      render json: ApiSerializer.render(api)
    else
      render json: { error: api.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk_upload
    apis_list.map do |api|
      api_built = {
        name:	api.dig('api', 'name'),
        acl: api.dig('api', 'acl'),
        api_environments_attributes: {
          metadata_url: api.dig('api', 'metadata_url'),
          environments_attributes: {
            name: api.dig('api', 'env_name')
          }
        },
        api_ref_attributes: {
          name: api.dig('api', 'api_ref')
        }
      }
      manage_api api_built
    end

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

  def manage_api(manage_params)
    api = Api.find_or_create_by(name: manage_params[:name])
    if api.persisted?
      api.update manage_params
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
      {
        'api' => {
          'name' => api['api_name'],
          'acl' => api['acl_ref'],
          'metadata_url' => api['metadata_url'],
          'env_name' => api['environment'],
          'api_ref' => api['api_ref']
        }
      }
    end
  end

  def api_params
    params.require(:api).permit(
      :name,
      :acl,
      api_environments_attributes: [
        :metadata_url,
        { environments_attributes: [:name] }
      ],
      api_ref_attributes: [:name]
    )
  end
end
