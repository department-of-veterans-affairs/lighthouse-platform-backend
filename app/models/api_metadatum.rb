# frozen_string_literal: true

class ApiMetadatum < ApplicationRecord
  include Discard::Model

  enum va_internal_only: {
    StrictlyInternal: 1,
    AdditionalDetails: 2,
    FlagOnly: 3
  }

  belongs_to :api
  belongs_to :api_category
  has_many :api_release_notes, dependent: :destroy
end
