# frozen_string_literal: true

class ProductionMailer < ApplicationMailer
  default from: Figaro.env.support_email

  def consumer_production_access(request)
    mail(to: Flipper.enabled?(:email_testing) ? 'lee.deboom@oddball.io' : request[:primaryContact][:email],
         from: 'VA API Platform team',
         subject: 'Your Request for Production Access is Submitted')
  end

  def support_production_access(request)
    @request = request
    mail(to: Flipper.enabled?(:email_testing) ? 'lee.deboom@oddball.io' : Figaro.env.support_email,
         from: "#{request[:primaryContact][:firstName]} #{request[:primaryContact][:lastName]}",
         subject: "Production Access Requested for #{request[:organization]}")
  end
end
