# frozen_string_literal: true

class Api < ApplicationRecord
  include Discard::Model

  validates :name, presence: true

  has_one :api_ref, dependent: :destroy
  has_many :consumer_api_assignment, dependent: :nullify
  has_many :api_environments, dependent: :destroy

  accepts_nested_attributes_for :api_ref, :api_environments

  def api_environments_attributes=(api_environments_attributes)
    environment = Environment.find_or_create_by(name: api_environments_attributes.dig(:environments_attributes, :name))
    api_environments << ApiEnvironment.create(metadata_url: api_environments_attributes[:metadata_url], 
                                              environment: environment)
  end
end
