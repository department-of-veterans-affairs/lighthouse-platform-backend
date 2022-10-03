# frozen_string_literal: true

class ProductionRequestContact < ApplicationRecord
  belongs_to :production_request
  belongs_to :user

  enum contact_type: [:primary, :secondary]
end
