# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@va.gov'
  layout 'mailer'
end
