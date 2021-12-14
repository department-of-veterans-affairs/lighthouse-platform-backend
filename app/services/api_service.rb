# frozen_string_literal: true

class ApiService
  def gather_apis(api_list)
    applied_for_apis = api_list.split(',')
    Api.kept.filter do |api|
      api.api_ref.present? && applied_for_apis.include?(api.api_ref.name)
    end
  end

  def fetch_auth_types(api_list)
    key_auth = []
    oauth = []
    gather_apis(api_list).map do |api|
      key_auth << api.acl if api.acl.present?
      oauth << api.auth_server_access_key if api.auth_server_access_key.present?
    end
    [key_auth, oauth]
  end
end
