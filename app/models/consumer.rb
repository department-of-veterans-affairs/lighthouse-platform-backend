# frozen_string_literal: true

class Consumer < ApplicationRecord
  attr_accessor :tos_accepted, :apis_list

  validates :description, presence: true

  belongs_to :user
  has_many :consumer_api_assignments, dependent: :destroy
  has_many :apis, through: :consumer_api_assignments

  accepts_nested_attributes_for :consumer_api_assignments

  before_save :manage_tos
  before_save :manage_apis

  private

  def manage_tos
    if new_record? && tos_accepted == false
      # raise an error
    elsif !persisted?
      self.tos_accepted_at = Time.zone.now
    end
  end

  # TODO: this needs to factor the api env also
  def manage_apis
    return if apis_list.blank?

    apis_list.split(',').map do |api|
      api_model = Api.find_by(api_ref: api.strip)
      apis << api_model if api_model.present? && api_ids.exclude?(api_model.id)
    end
  end
end
