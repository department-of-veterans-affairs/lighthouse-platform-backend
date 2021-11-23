# frozen_string_literal: true

class ApiRef < ApplicationRecord
  has_many :apis

  validates :name, presence: true
end
