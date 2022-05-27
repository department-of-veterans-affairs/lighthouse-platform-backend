# frozen_string_literal: true

class ApiService
  AUTH_TYPES = %w[acg ccg apikey].freeze

  def self.parse(api_list_str)
    api_list = api_list_str.strip.split(',')
    api_list.map do |api|
      api_parts = api.strip.split('/')
      raise invalid_api_exception(api) if api_parts.blank? || api_parts.count > 2

      api_ref = ApiRef.kept.find_by(name: api_parts.last)
      raise invalid_api_exception(api) if api_ref.blank?

      api = api_ref.api
      api.auth_type = api_parts.count > 1 ? validate_auth_type(api_parts.first) : default_auth_type(api)

      api
    end
  end

  def self.validate_auth_type(auth_type)
    raise "Invalid auth type: #{auth_type}" unless AUTH_TYPES.include?(auth_type)

    auth_type
  end

  def self.default_auth_type(api)
    api.auth_server_access_key.present? ? 'acg' : 'apikey'
  end

  def self.invalid_api_exception(api)
    Grape::Exceptions::Validation.new(params: %w[apis], message: "invalid api provided: #{api}")
  end
end
