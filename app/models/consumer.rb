class Consumer < ApplicationRecord
  attr_accessor :tos_accepted

  belongs_to :user

  before_save :manage_tos

  def manage_tos
    if self.new_record? && self.tos_accepted == false
      # raise an error
    elsif !self.persisted?
      self.tos_accepted_at = Time.zone.now
    end
  end
end
