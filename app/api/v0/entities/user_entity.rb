# frozen_string_literal: true

module V0
  module Entities
    class UserEntity < Grape::Entity
      expose :id
      expose :email
      expose :first_name, as: :firstName
      expose :last_name, as: :lastName
      expose :role
      expose :provider
      expose :consumer, using: V0::Entities::ConsumerEntity
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end
end
