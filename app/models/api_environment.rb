# frozen_string_literal: true

class ApiEnvironment < ApplicationRecord
  belongs_to :api
  belongs_to :environment

  def environments_attributes=(environments_attributes)
    self.environment = Environment.find_or_create_by(name: environments_attributes[:name])
  end
end
