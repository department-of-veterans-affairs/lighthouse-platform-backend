# frozen_string_literal: true

class ApiCategory < ApplicationRecord
  include Discard::Model

  validates :key, uniqueness: true
  validates :url_slug, presence: true

  has_many :api_metadatum, -> { order(:display_name) }, dependent: :nullify, inverse_of: :api_category
end
