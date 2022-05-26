# frozen_string_literal: true

module V0
  module Entities
    class ConsumerEntity < Grape::Entity
      expose :id
      expose :email do |consumer, _options|
        consumer.user.email
      end
      expose :first_name, as: :firstName do |consumer, _options|
        consumer.user.first_name
      end
      expose :last_name, as: :lastName do |consumer, _options|
        consumer.user.last_name
      end
    end
  end
end
