# frozen_string_literal: true

class ApiRef < ApplicationRecord
  has_one :api, dependent: :destroy

  validates :name, presence: true
end
