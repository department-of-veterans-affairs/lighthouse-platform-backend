# frozen_string_literal: true

class ProductionRequestContact < ApplicationRecord
  belongs_to :production_request

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
end
