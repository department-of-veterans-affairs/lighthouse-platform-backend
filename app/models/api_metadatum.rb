# frozen_string_literal: true

class ApiMetadatum < ApplicationRecord
  include Discard::Model

  enum va_internal_only: {
    StrictlyInternal: 'StrictlyInternal',
    AdditionalDetails: 'AdditionalDetails',
    FlagOnly: 'FlagOnly'
  }

  belongs_to :api
  belongs_to :api_category
  has_many :api_release_notes, dependent: :destroy
end
