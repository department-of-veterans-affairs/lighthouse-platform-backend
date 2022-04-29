# frozen_string_literal: true

class SupportMailer < ApplicationMailer
  def consumer_support_email(request)
    @request = request
    mail(to: Figaro.env.support_email,
         from: (request[:requester]).to_s,
         subject: 'Support Needed')
  end

  def publishing_support_email(request)
    @request = request
    mail(to: Figaro.env.support_email,
         from: (request[:requester]).to_s,
         subject: 'Publishing Support Needed')
  end
end
