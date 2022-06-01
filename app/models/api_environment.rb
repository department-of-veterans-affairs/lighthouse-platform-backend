# frozen_string_literal: true

class ApiEnvironment < ApplicationRecord
  include Discard::Model

  belongs_to :api
  belongs_to :environment
  has_many :consumer_api_assignment, dependent: :destroy

  def environments_attributes=(environments_attributes)
    self.environment = Environment.find_or_create_by(name: environments_attributes[:name])
  end
end
