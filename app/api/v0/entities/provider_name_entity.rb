# frozen_string_literal: true

module V0
  module Entities
    class ProviderNameEntity < Grape::Entity
      expose :providerName, documentation: { type: String } do |_user, options|
        options[:provider_name]
      end
    end
  end
end
