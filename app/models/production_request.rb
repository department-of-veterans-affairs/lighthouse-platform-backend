# frozen_string_literal: true

class ProductionRequest < ApplicationRecord
  has_many :apis_production_requests, dependent: :destroy
  has_many :apis, through: :apis_production_requests
  has_many :production_request_contacts, dependent: :destroy
  has_one :primary_contact, -> { where(contact_type: 'primary') },
          class_name: 'ProductionRequestContact',
          inverse_of: :production_request,
          dependent: :destroy
  has_one :secondary_contact, -> { where(contact_type: 'secondary') },
          class_name: 'ProductionRequestContact',
          inverse_of: :production_request,
          dependent: :destroy

  validates :apis, presence: true
  validates :organization, presence: true
  validates :primary_contact, presence: true
  validates :secondary_contact, presence: true
  validates :status_update_emails, presence: true
  validates :value_provided, presence: true
end
