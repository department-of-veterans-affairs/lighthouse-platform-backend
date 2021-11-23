# frozen_string_literal: true

class ApiSerializer
  include JSONAPI::Serializer
  attributes :id, :name
end
