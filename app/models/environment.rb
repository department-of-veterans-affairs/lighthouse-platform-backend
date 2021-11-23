#frozen_string_literal: true

class Environment < ApplicationRecord
  has_many :api_environments, dependent: :destroy
  has_many :apis, through: :api_environments

  validates :name, presence: true, uniqueness: true
end
