# frozen_string_literal: true

module V0
  module Entities
    class ApiRefEntity < Grape::Entity
      expose :id
      expose :name, documentation: { type: 'String' }
    end
  end
end
