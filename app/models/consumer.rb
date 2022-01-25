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
      environment = Environment.find_by(name: Figaro.env.lpb_environment)
      if environment && api_id
        api_env = ApiEnvironment.find_by(environment: environment, api_id: api_id)
        if api_env
          consumer_api_assignment = ConsumerApiAssignment.find_or_initialize_by(consumer: self,
                                                                                api_environment: api_env)
          unless consumer_api_assignments.include?(consumer_api_assignment)
            consumer_api_assignments << consumer_api_assignment
          end
        end
      end
    end
  end
end
