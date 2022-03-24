# frozen_string_literal: true

module V0
  module Entities
    class ApiMetadatumEntity < Grape::Entity
      expose :id
      expose :display_name, as: :displayName, documentation: { type: 'String' }
      expose :va_internal_only, as: :vaInternalOnly, documentation: { type: 'Boolean' }
    end
  end
end
