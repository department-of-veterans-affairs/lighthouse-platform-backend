# frozen_string_literal: true

class Api < ApplicationRecord
  has_many :consumer_api_assignment, dependent: :nullify

  validates :name, :auth_method, :environment, :base_path, :service_ref, presence: true
  validates :api_ref, presence: true, uniqueness: { scope: :environment }
end
