# frozen_string_literal: true

module Entities
  class ExportEntity < Grape::Entity
    expose :developer, with: Entities::DeveloperEntity
    expose :keys, with: Entities::KeysEntity
  end
end
