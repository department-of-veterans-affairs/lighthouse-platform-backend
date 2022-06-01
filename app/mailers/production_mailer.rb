# frozen_string_literal: true

class ProductionMailer < ApplicationMailer
  def consumer_production_access(request)
    mail(to: request[:primaryContact][:email],
         from: from_email_wrapper('VA API Platform team'),
         subject: 'Your Request for Production Access is Submitted')
  end

  def support_production_access(request)
    @request = request
    mail(to: Figaro.env.support_email,
         from: from_email_wrapper("#{request[:primaryContact][:firstName]} #{request[:primaryContact][:lastName]}"),
         subject: "Production Access Requested for #{request[:organization]}")
  end
end
