# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # NOTE: Do not include default "from" here
  #   govdelivery-tms gem handles the from and reply-to fields and will complain if non-standard values are given

  layout 'mailer'

  protected

  def from_email_wrapper(from_name)
    from_email_address = if Rails.configuration.action_mailer.delivery_method == :govdelivery_tms
                           client = GovDelivery::TMS::Client.new(Figaro.env.govdelivery_key,
                                                                 api_root: Figaro.env.govdelivery_host)
                           client.from_addresses.get.collection.first.from_email
                         else
                           'no-reply@va.gov' # for testing and local development purposes
                         end

    "\"#{from_name}\"<#{from_email_address}>"
  end
end
