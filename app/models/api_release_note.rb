# frozen_string_literal: true

class ApiReleaseNote < ApplicationRecord
  include Discard::Model

  belongs_to :api_metadatum

  validates :date, presence: true
  validates :content, presence: true
end
