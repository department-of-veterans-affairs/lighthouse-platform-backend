# frozen_string_literal: true

module V0
  module Entities
    class ConsumerStatisticEntity < Grape::Entity
      expose :firstSandboxInteractionAt
    end
  end
end
