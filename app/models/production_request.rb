# frozen_string_literal: true

class ProductionRequest < ApplicationRecord
  has_and_belongs_to_many :apis
  has_many :production_request_contacts
  has_one :primary_contact, -> { where(contact_type: 'primary') }, class_name: 'ProductionRequestContact'
  has_one :secondary_contact, -> { where(contact_type: 'secondary') }, class_name: 'ProductionRequestContact'

  validates :apis, presence: true
  validates :organization, presence: true
  validates :primary_contact, presence: true
  validates :secondary_contact, presence: true
  validates :status_update_emails, presence: true
  validates :value_provided, presence: true
end
