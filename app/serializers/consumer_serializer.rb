# frozen_string_literal: true

class ConsumerSerializer < Blueprinter::Base
  identifier :id
  field :description
  field :organization
  field :tos_accepted_at
  field :tos_version
  field :sandbox_oauth_ref
  field :sandbox_gateway_ref
  field :prod_oauth_ref
  field :prod_gateway_ref
end
