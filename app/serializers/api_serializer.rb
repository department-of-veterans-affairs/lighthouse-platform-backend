# frozen_string_literal: true

class ApiSerializer < Blueprinter::Base
  identifier :id
  field :name
  association :api_ref, blueprint: ApiRefSerializer
  association :api_environments, blueprint: ApiEnvironmentSerializer
  field :created_at
end
