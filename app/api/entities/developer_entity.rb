# frozen_string_literal: true

module Entities
  class DeveloperEntity < Grape::Entity
    expose :email
    expose :username
    expose :firstName
    expose :lastName
  end
end
