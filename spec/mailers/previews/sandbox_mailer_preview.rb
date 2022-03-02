# frozen_string_literal: true

require 'factory_bot_rails'

class SandboxMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def consumer_sandbox_signup
    SandboxMailer.consumer_sandbox_signup(sandbox_request, kong_consumer, okta_consumer)
  end

  def consumer_sandbox_signup_key_auth_only
    SandboxMailer.consumer_sandbox_signup(sandbox_request, kong_consumer, nil)
  end

  def consumer_sandbox_signup_oauth_only
    SandboxMailer.consumer_sandbox_signup(sandbox_request, nil, okta_consumer)
  end

  def va_profile_sandbox_signup
    SandboxMailer.va_profile_sandbox_signup(sandbox_request)
  end

  private

  def sandbox_request
    build(:sandbox_signup_request, :generate_apis)
  end

  def kong_consumer
    build(:kong_consumer)
  end

  def okta_consumer
    build(:okta_consumer)
  end
end
