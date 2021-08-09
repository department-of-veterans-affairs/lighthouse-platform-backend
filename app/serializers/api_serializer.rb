# frozen_string_literal: true

class ApiSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :auth_method, :environment, :base_path, :service_ref, :api_ref
end
