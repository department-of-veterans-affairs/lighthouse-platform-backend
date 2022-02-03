# frozen_string_literal: true

class Api < ApplicationRecord
  include Discard::Model

  validates :name, presence: true

  has_one :api_ref, dependent: :destroy
  has_many :consumer_api_assignment, dependent: :nullify
  has_many :api_environments, dependent: :destroy
  has_one :api_metadatum, dependent: :destroy

  after_discard do
    api_ref.discard if api_ref.present?
    api_environments.discard_all if api_environments.present?
  end

  after_undiscard do
    api_ref.undiscard if api_ref.present?
    api_environments.undiscard_all if api_environments.present?
  end

  def api_environments_attributes=(api_environments_attributes)
    environment = Environment.find_or_create_by(name: api_environments_attributes.dig(:environments_attributes, :name))
    api_environments << ApiEnvironment.find_or_create_by(metadata_url: api_environments_attributes[:metadata_url],
                                                         environment: environment)
  end

  def api_ref_attributes=(api_ref_attributes)
    ApiRef.find_or_create_by(name: api_ref_attributes[:name], api_id: id)
  end

  def api_metadatum_attributes=(api_metadatum_attributes)
    ApiMetadatum.find_or_create_by(api_id: id,
                                   description: api_metadatum_attributes[:description],
                                   enabled_by_default: api_metadatum_attributes[:enabled_by_default],
                                   display_name: api_metadatum_attributes[:display_name],
                                   open_data: api_metadatum_attributes[:open_data],
                                   va_internal_only: api_metadatum_attributes[:va_internal_only])
  end
end
