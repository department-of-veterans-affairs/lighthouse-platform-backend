# frozen_string_literal: true

class Api < ApplicationRecord
  include Discard::Model

  attr_accessor :auth_type

  validates :name, presence: true
  validates :name, uniqueness: true

  has_one :api_ref, dependent: :destroy
  has_many :api_environments, dependent: :destroy
  has_one :api_metadatum, dependent: :destroy

  scope :displayable, -> { joins(:api_metadatum) }

  after_discard do
    api_ref.discard if api_ref.present?
    api_environments.discard_all if api_environments.present?
  end

  after_undiscard do
    api_ref.undiscard if api_ref.present?
    api_environments.undiscard_all if api_environments.present?
  end

  def status
    kept? ? 'active' : 'inactive'
  end

  def activate!
    self.deactivation_info = nil
    save!

    undiscard! if discarded?
  end

  def deactivate!(deactivation_content: '', deactivation_date: Time.zone.now)
    temp = api_metadatum.deactivation_info.present? ? JSON.parse(api_metadatum.deactivation_info) : {}
    temp[:deactivationContent] = deactivation_content
    temp[:deactivationDate] = deactivation_date

    metadatum = api_metadatum
    metadatum.deactivation_info = temp.to_json
    metadatum.save!

    discard! if undiscarded?
  end

  def deprecate!(deprecation_content: '', deprecation_date: Time.zone.now)
    temp = api_metadatum.deactivation_info.present? ? JSON.parse(api_metadatum.deactivation_info) : {}
    temp[:deprecationContent] = deprecation_content
    temp[:deprecationDate] = deprecation_date

    metadatum = api_metadatum
    metadatum.deactivation_info = temp.to_json
    metadatum.save!

    discard! if undiscarded?
  end

  def api_environments_attributes=(api_environments_attributes)
    api_environments_attributes[:environments_attributes][:name].map do |envs|
      environment = Environment.find_or_create_by(name: envs)
      api_environments << ApiEnvironment.find_or_create_by(metadata_url: api_environments_attributes[:metadata_url],
                                                           environment: environment)
    end
  end

  def api_ref_attributes=(api_ref_attributes)
    ApiRef.find_or_create_by(name: api_ref_attributes[:name], api_id: id)
  end

  def api_metadatum_attributes=(api_metadatum_attributes)
    category = ApiCategory.find_by(id: api_metadatum_attributes.dig(:api_category_attributes, :id))
    ApiMetadatum.find_or_create_by(api_id: id,
                                   description: api_metadatum_attributes[:description],
                                   display_name: api_metadatum_attributes[:display_name],
                                   open_data: api_metadatum_attributes[:open_data],
                                   va_internal_only: api_metadatum_attributes[:va_internal_only],
                                   url_fragment: api_metadatum_attributes[:url_fragment],
                                   oauth_info: api_metadatum_attributes[:oauth_info],
                                   multi_open_api_intro: api_metadatum_attributes[:multi_open_api_intro],
                                   api_category: category)
  end
end
