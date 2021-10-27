# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true

  has_one :consumer, dependent: :destroy
  has_many :consumer_api_assignment, through: :consumer
  accepts_nested_attributes_for :consumer

  protected

  def password_required?
    false
  end
end
