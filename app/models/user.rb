# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  validates :first_name, :last_name, presence: true

  has_one :consumer, dependent: :destroy
  has_many :consumer_api_assignment, through: :consumer
  accepts_nested_attributes_for :consumer

  protected

  def password_required?
    false
  end

  def self.from_omniauth(auth, is_admin)
    user = first_or_create_user auth, is_admin

    update_user user, auth, is_admin
    user
  end

  private_class_method def self.first_or_create_user(auth, is_admin)
  where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.email = auth.info.email
      u.first_name = auth.info.name.split().first
      u.last_name = auth.info.name.split().last
      u.role = is_admin ? 'admin' : 'user'
    end
  end

  private_class_method def self.update_user(user, auth, is_admin)
    user.update(
      email: auth.info.email,
      first_name: auth.info.name.split().first,
      last_name: auth.info.name.split().last,
      role: is_admin ? 'admin' : 'user'
    )
  end
end
