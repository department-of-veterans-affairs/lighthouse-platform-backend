# frozen_string_literal: true

class ApisProductionRequest < ApplicationRecord
  belongs_to :api
  belongs_to :production_request
end
