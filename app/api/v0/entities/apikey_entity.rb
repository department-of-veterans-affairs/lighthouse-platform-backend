# frozen_string_literal: true

module V0
  module Entities
    class ApikeyEntity < ProviderNameEntity
      expose :apikey, documentation: { type: String } do |_user, options|
        options.dig(:kong_consumer, :token)
      end
    end
  end
end
