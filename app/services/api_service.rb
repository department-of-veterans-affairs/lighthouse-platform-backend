# frozen_string_literal: true

class ApiService
  def gather_apis(api_list)
    applied_for_apis = api_list.split(',')
    Api.all.filter do |api|
      api.api_ref.present? && applied_for_apis.include?(api.api_ref.name)
    end
  end

  def fetch_auth_types(api_list)
    key_auth = []
    oauth = []
    gather_apis(api_list).map do |api|
      if api.acl.present?
        key_auth << api.acl
      else
        oauth << api
      end
    end
    [key_auth, oauth]
  end
end
