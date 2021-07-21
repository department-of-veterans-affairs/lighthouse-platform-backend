class Api < ApplicationRecord
  has_many :consumer_api_assignment

  validates :api_ref, presence: true, uniqueness: {scope: :environment}
end
