# frozen_string_literal: true

class Consumer < ApplicationRecord
  attr_accessor :tos_accepted, :apis_list

  validates :description, :organization, presence: true
  validate :confirm_tos

  belongs_to :user
  has_many :consumer_api_assignments, dependent: :destroy
  has_many :apis, through: :consumer_api_assignments

  accepts_nested_attributes_for :consumer_api_assignments

  before_save :set_tos
  before_save :manage_apis

  def self.create_from_import(consumer, params)
    consumer.description = params['description']
    consumer.organization = params['organization']
    consumer.sandbox_gateway_ref = params['kong_id'] if params['kong_id'].present?
    consumer.sandbox_oauth_ref = params['okta_id'] if params['okta_id'].present?
    consumer.tos_accepted_at = Time.zone.now
    consumer.tos_version = Figaro.env.current_tos_version
    consumer.save
    params[:apis].split(',').each do |api_name|
      api = Api.find_by api_ref: api_name
      consumer.apis << api if api.present?
    end
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
      api_model = Api.find_by(api_ref: api.strip, environment: 'sandbox')
      apis << api_model if api_model.present? && api_ids.exclude?(api_model.id)
    end
  end
end
