# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # NOTE: Do not include default "from" here
  #   govdelivery-tms gem handles the from and reply-to fields and will complain if non-standard values are given

  layout 'mailer'
end
