# frozen_string_literal: true

class ConsumerSerializer
  include JSONAPI::Serializer
  attributes  :id,
              :description,
              :organization,
              :tos_accepted_at,
              :tos_version,
              :sandbox_oauth_ref,
              :sandbox_gateway_ref,
              :prod_oauth_ref,
              :prod_gateway_ref
end
