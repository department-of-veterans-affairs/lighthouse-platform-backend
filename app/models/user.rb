class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates_presence_of :first_name, :last_name, :organization

  has_one :consumer
  has_many :consumer_api_assignment, through: :consumer
  accepts_nested_attributes_for :consumer

  protected

  def password_required?
    return false
  end
end
