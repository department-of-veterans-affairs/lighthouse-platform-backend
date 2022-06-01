# frozen_string_literal: true

class ApiRef < ApplicationRecord
  include Discard::Model

  belongs_to :api

  validates :name, presence: true
end
