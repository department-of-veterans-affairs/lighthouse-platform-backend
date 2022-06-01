# frozen_string_literal: true

module V0
  module Entities
    class ConsumerStatisticEntity < Grape::Entity
      expose :first_sandbox_interaction_at, as: :firstSandboxInteractionAt
    end
  end
end
