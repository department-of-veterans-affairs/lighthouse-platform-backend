# frozen_string_literal: true

module Entities
  class ErrorEntity < Grape::Entity
    expose :title, documentation: { type: String }
    expose :detail, documentation: { type: String }
  end
end
