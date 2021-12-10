# frozen_string_literal: true

class ApiEnvironmentSerializer < Blueprinter::Base
  field :metadata_url
  association :environment, blueprint: EnvironmentSerializer
end
