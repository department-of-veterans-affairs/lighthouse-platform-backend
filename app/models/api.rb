# frozen_string_literal: true

class Api < ApplicationRecord
  has_many :consumer_api_assignment, dependent: :nullify

  validates_presence_of :name, :auth_method, :environment, :open_api_url, :base_path, :service_ref
  validates :api_ref, presence: true, uniqueness: { scope: :environment }
end
