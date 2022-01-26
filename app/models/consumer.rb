# frozen_string_literal: true

class Consumer < ApplicationRecord
  include Discard::Model

  attr_accessor :tos_accepted, :apis_list

  validates :description, :organization, presence: true
  validate :confirm_tos

  belongs_to :user
  has_many :consumer_api_assignments, dependent: :destroy
  has_many :api_environments, through: :consumer_api_assignments

  accepts_nested_attributes_for :consumer_api_assignments

  before_save :set_tos
  before_save :manage_apis

  after_discard do
    consumer_api_assignments.discard_all if consumer_api_assignments.present?
  end

  after_undiscard do
    consumer_api_assignments.undiscard_all if consumer_api_assignments.present?
  end

  def apis
    api_environments.map(&:api)
  end

  def api_ids
    apis.map(&:id)
  end

  private

  def confirm_tos
    errors.add(:tos_accepted, 'is invalid.') if new_record? && tos_accepted == 'false'
  end

  def set_tos
    self.tos_accepted_at = Time.zone.now unless persisted?
  end

  def manage_apis
    return if apis_list.blank?

    apis_list.split(',').map do |api|
      api_ref = ApiRef.find_by(name: api.strip)
      next if api_ref.blank?

      api_id = api_ref['api_id']
      api_model = Api.find(api_id)
      env = Environment.find_by(name: 'dev')
      api_environment = ApiEnvironment.find_by(environment: env, api: api_model)
      api_environments << api_environment if api_environment.present? && api_environment_ids.exclude?(api_environment.id)
    end
  end
end
