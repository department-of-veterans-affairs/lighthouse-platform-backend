# frozen_string_literal: true

module V0
  module Entities
    class LinkEntity < Grape::Entity
      expose :rel, documentation: { type: String }
      expose :type, documentation: { type: String }
      expose :url, documentation: { type: String }
    end
  end
end
