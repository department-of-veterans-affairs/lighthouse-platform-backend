# frozen_string_literal: true

class Environment < ApplicationRecord
  include Discard::Model

  validates :name, presence: true

  has_many :api_environments, dependent: :destroy
  has_many :apis, through: :api_environments

  def apis_attributes=(apis_attributes)
    api = Api.find_or_create_by(name: apis_attributes[:name])
    api_values = extract_api apis_attributes
    if api.persisted?
      api.update api_values
    else
      api.assign_attributes api_values
    end
    ApiRef.find_or_create_by(name: apis_attributes[:api_ref], api_id: api.id) unless apis_attributes[:api_ref].nil?
    ApiEnvironment.find_or_create_by(metadata_url: apis_attributes[:metadata_url], api: api, environment: self)
  end

  private

  def extract_api(api_attributes)
    {}.tap do |api|
      api[:name] = api_attributes[:name]
      api[:acl] = api_attributes[:acl]
      api[:auth_server_access_key] = api_attributes[:auth_server_access_key]
    end
  end
end
