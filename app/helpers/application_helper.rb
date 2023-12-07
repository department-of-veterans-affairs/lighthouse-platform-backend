# frozen_string_literal: true
require 'digest'

module ApplicationHelper
  def generate_deeplink_hash(user)
    salt = ENV.fetch('DEEPLINK_SALT')
    email = user.email
    Digest::SHA256.hexdigest "#{salt}-#{email}"
  end

  def generate_deeplink(url_slug, user)
    hash = generate_deeplink_hash(user)
    "/explore/api/#{url_slug}/test-user-data/#{user.id}/#{hash}"
  end

  def validate_deeplink_hash(user_id, hash)
    begin
      user = User.find(user_id)
      salt = ENV.fetch('DEEPLINK_SALT')
      email = user.email
      expected_hash = Digest::SHA256.hexdigest "#{salt}-#{email}"

      hash === expected_hash  
    rescue 
      false
    end
  end
end
