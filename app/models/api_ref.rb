# frozen_string_literal: true

class ApiRef < ApplicationRecord
  belongs_to :api

  validates :name, presence: true
end
