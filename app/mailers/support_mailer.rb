# frozen_string_literal: true

class SupportMailer < ApplicationMailer
  def consumer_support_email(request)
    @request = request
    mail(to: Flipper.enabled?(:email_testing) ? 'lee.deboom@oddball.io' : Figaro.env.support_email,
         from: "#{request[:firstName]} #{request[:lastName]}",
         subject: 'Support Needed')
  end

  def publishing_support_email(request)
    @request = request
    mail(to: Flipper.enabled?(:email_testing) ? 'lee.deboom@oddball.io' : Figaro.env.support_email,
         from: "#{request[:firstName]} #{request[:lastName]}",
         subject: 'Publishing Support Needed')
  end
end
