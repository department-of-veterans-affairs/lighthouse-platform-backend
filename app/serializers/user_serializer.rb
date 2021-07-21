# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :first_name, :last_name, :organization

  has_one :consumer, if: proc { |record| record.consumer.present? }
end
