# frozen_string_literal: true

class Consumer < ApplicationRecord
  include Discard::Model

  attr_accessor :tos_accepted, :apis_list

  validate :confirm_tos

  belongs_to :user
  has_many :consumer_api_assignments, dependent: :destroy
  has_many :api_environments, through: :consumer_api_assignments
  has_many :consumer_auth_refs, dependent: :destroy

  accepts_nested_attributes_for :consumer_api_assignments
  accepts_nested_attributes_for :consumer_auth_refs

  before_save :set_tos
  before_save :manage_apis

  after_discard do
    consumer_api_assignments.discard_all if consumer_api_assignments.present?
    consumer_auth_refs.discard_all if consumer_auth_refs.present?
  end

  after_undiscard do
    consumer_api_assignments.undiscard_all if consumer_api_assignments.present?
    consumer_auth_refs.undiscard_all if consumer_auth_refs.present?
  end

  def apis
    api_environments.map(&:api)
  end

  def api_ids
    apis.map(&:id)
  end

  def promote_to_prod(api_ref)
    api = ApiRef.find_by(name: api_ref).api
    raise 'API not found' if api.nil?

    env = Environment.find_by(name: 'production')
    api_environment = ApiEnvironment.find_by(api: api, environment: env)
    api_environments << api_environment if api_environment.present? && api_environment_ids.exclude?(api_environment.id)
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

    apis_list.map do |api|
      next if api.api_ref.blank?

      assign_api_environments(api.api_ref)
    end
  end

  def assign_api_environments(api_ref)
    api_id = api_ref['api_id']
    api_model = Api.find(api_id)
    env = Environment.find_by(name: 'sandbox')
    api_environment = ApiEnvironment.find_by(environment: env, api: api_model)
    api_environments << api_environment if api_environment.present? && api_environment_ids.exclude?(api_environment.id)
  end
end
