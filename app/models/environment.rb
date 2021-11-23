# frozen_string_literal: true

class Environment < ApplicationRecord
  has_many :api_environments, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
