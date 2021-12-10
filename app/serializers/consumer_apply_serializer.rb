# frozen_string_literal: true

class ConsumerApplySerializer < Blueprinter::Base
  field :apis
  field :clientId
  field :clientSecret
  field :email
  field :kongUsername
  field :token
  field :redirectURI
end
