# frozen_string_literal: true

class Api < ApplicationRecord
  include Discard::Model

  # attr_accessor :metadata_url

  validates :name, presence: true

  has_one :api_ref, dependent: :destroy
  has_many :consumer_api_assignment, dependent: :nullify

  has_many :api_environments, dependent: :destroy
  has_many :environments, through: :api_environments

  accepts_nested_attributes_for :api_ref, :environments, :api_environments

  # before_save :add_metadata_url

  def environments_attributes=(environments_attributes)
    environments << Environment.find_or_create_by(name: environments_attributes[:name])
  end
  
  # def api_environments_attributes=(api_environments_attributes)
  #   api_environments << ApiEnvironment.create(api_id: self.id, environment_id: Environment.first.id, metadata_url: 'Lee da bes')
  # end

  private

  # def add_metadata_url
  #   self.api_environments.last.assign_attributes(metadata_url: metadata_url)
  # end
end
