# frozen_string_literal: true

require 'factory_bot_rails'

class SandboxMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def consumer_sandbox_signup
    SandboxMailer.consumer_sandbox_signup(sandbox_request, kong_consumer, okta_consumers)
  end

  def consumer_sandbox_signup_key_auth_only
    SandboxMailer.consumer_sandbox_signup(sandbox_request, kong_consumer, nil)
  end

  def consumer_sandbox_signup_acg_oauth_only
    SandboxMailer.consumer_sandbox_signup(sandbox_request, nil, { acg: okta_consumers[:acg] })
  end

  def consumer_sandbox_signup_ccg_oauth_only
    SandboxMailer.consumer_sandbox_signup(sandbox_request, nil, { ccg: okta_consumers[:ccg] })
  end

  def va_profile_sandbox_signup
    SandboxMailer.va_profile_sandbox_signup(sandbox_request)
  end

  private

  def sandbox_request
    build(:sandbox_signup_request, :generate_apis_after_parse)
  end

  def kong_consumer
    build(:kong_consumer)
  end

  def okta_consumers
    { acg: build(:okta_consumer), ccg: build(:okta_consumer) }
  end
end
