# frozen_string_literal: true

class ProductionMailer < ApplicationMailer
  def consumer_production_access(request)
    mail(to: request[:primaryContact][:email],
         subject: 'Your Request for Production Access is Submitted')
  end

  def support_production_access(request)
    @request = request
    mail(to: Figaro.env.support_email,
         subject: "Production Access Requested for #{request[:organization]}")
  end
end
