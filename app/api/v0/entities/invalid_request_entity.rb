# frozen_string_literal: true

module V0
  module Entities
    class InvalidRequestEntity < Grape::Entity
      expose :title, documentation: { type: 'String' }
      expose :detail, documentation: { type: 'String' }
    end
  end
end
