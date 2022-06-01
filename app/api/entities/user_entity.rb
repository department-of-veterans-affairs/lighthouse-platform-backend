# frozen_string_literal: true

module Entities
  class UserEntity < Grape::Entity
    expose :id
    expose :email
    expose :first_name, as: :firstName
    expose :last_name, as: :lastName
    expose :role
    expose :provider
    expose :consumer, using: Entities::ConsumerEntity
    expose :created_at, as: :createdAt
    expose :updated_at, as: :updatedAt
  end
end
