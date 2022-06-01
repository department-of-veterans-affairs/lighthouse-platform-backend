# frozen_string_literal: true

class Environment < ApplicationRecord
  include Discard::Model

  has_many :api_environments, dependent: :destroy

  validates :name, presence: true
end
