# frozen_string_literal: true

require 'csv'

class Admin::Api::V0::EnvironmentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    environment = Environment.find_or_create_by(name: environment_params[:name])

    unless environment.errors.empty?
      render json: { error: environment.errors.full_messages },
             status: :unprocessable_entity
    end

    render json: EnvironmentSerializer.render(environment)
  end

  def bulk_upload
    environments_list.map do |environment|
      environment_built = build_environment environment

      manage_environment environment_built
    end

    if params[:authenticity_token].present?
      redirect_to admin_dashboard_path
    else
      render json: { data: 'apis_uploaded' }
    end
  end

  def destroy_all
    Environment.discard_all

    redirect_to admin_dashboard_path
  end

  private

  def build_environment(environment)
    {
      name: environment.dig('environment', 'env_name'),
      apis_attributes: {
        metadata_url: environment.dig('environment', 'metadata_url'),
        name:	environment.dig('environment', 'name'),
        acl: environment.dig('environment', 'acl'),
        auth_server_access_key: environment.dig('environment', 'auth_server_access_key'),
        api_ref: environment.dig('environment', 'api_ref')
      }
    }
  end

  def manage_environment(manage_params)
    environment = Environment.find_or_create_by(name: manage_params[:name])
    if environment.persisted?
      environment.update manage_params
    else
      environment.assign_attributes manage_params
    end

    environment
  end

  def environments_list
    return params[:environments] if params[:environments].present?
    return [] if params[:environments].blank? && params[:file].blank?

    file_content = CSV.parse(File.read(params[:file].tempfile), headers: true)
    file_content.map { |env| handle_env_structure(env) }
  end

  def handle_env_structure(env)
    {
      'environment' => {
        'name' => env['api_name'],
        'acl' => env['acl_ref'],
        'auth_server_access_key' => env['auth_server_access_key'],
        'metadata_url' => env['metadata_url'],
        'env_name' => env['environment'],
        'api_ref' => env['api_ref']
      }
    }
  end

  def environment_params
    params.require(:environment).permit(:name)
  end
end
