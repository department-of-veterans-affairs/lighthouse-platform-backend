class Consumer < ApplicationRecord
  attr_accessor :tos_accepted, :apis_list, :apis

  belongs_to :user
  has_many :consumer_api_assignment

  accepts_nested_attributes_for :consumer_api_assignment

  before_save :manage_tos
  before_save :manage_apis

  private

  def manage_tos
    if self.new_record? && self.tos_accepted == false
      # raise an error
    elsif !self.persisted?
      self.tos_accepted_at = Time.zone.now
    end
  end

  def manage_apis
    apis = []
    self.apis_list.split(',').map do |api|
      api_model = Api.find_by(api_ref: api.strip)
      apis << api_model if api_model.present?
    end
    self.apis = apis
  end
end
