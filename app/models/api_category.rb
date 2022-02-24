# frozen_string_literal: true

class ApiCategory < ApplicationRecord
  include Discard::Model

  has_many :api_metadatum, dependent: :nullify
end
