module V0
  module Entities
    class ErrorEntity < Grape::Entity
      expose :title, documentation: { type: String }
      expose :detail, documentation: { type: String }
    end
  end
end
