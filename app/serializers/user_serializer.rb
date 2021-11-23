# frozen_string_literal: true

class UserSerializer < Blueprinter::Base
  identifier :id
  field :email
  field :first_name
  field :last_name
  association :consumer, blueprint: ConsumerSerializer
  field :created_at
end
