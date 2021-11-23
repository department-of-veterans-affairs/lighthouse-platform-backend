# frozen_string_literal: true

class ApiEnvironment < ApplicationRecord
  belongs_to :api
  belongs_to :environment
end
