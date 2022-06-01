# frozen_string_literal: true

class SandboxMailer < ApplicationMailer
  helper :mailer

  def consumer_sandbox_signup(request, kong_consumer, okta_consumers)
    @request = request
    @kong_consumer = kong_consumer
    @okta_consumers = okta_consumers
    mail(to: request[:email],
         from: from_email_wrapper('VA API Platform team'),
         subject: 'Welcome to the VA API Platform')
  end

  def va_profile_sandbox_signup(request)
    @request = request
    mail(to: Figaro.env.va_profile_distribution,
         from: from_email_wrapper("#{request[:firstName]} #{request[:lastName]}"),
         subject: 'VA Profile Signup Request')
  end
end
