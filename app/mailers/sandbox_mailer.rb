# frozen_string_literal: true

class SandboxMailer < ApplicationMailer
  helper :mailer

  def consumer_sandbox_signup(request, kong_consumer, okta_consumer)
    @request = request
    @kong_consumer = kong_consumer
    @okta_consumer = okta_consumer
    mail(to: request[:email],
         from: Figaro.env.support_email,
         reply_to: Figaro.env.support_email,
         subject: 'Welcome to the VA API Platform')
  end

  def va_profile_sandbox_signup(request)
    @request = request
    mail(to: Figaro.env.va_profile_distribution,
         from: 'no-reply@va.gov',
         subject: 'VA Profile Signup Request')
  end
end
