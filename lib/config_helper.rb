# frozen_string_literal: true

module ConfigHelper
  module_function

  def setup_action_mailer(config)
    config.action_mailer.perform_caching = false
    config.action_mailer.delivery_method = :govdelivery_tms
    config.action_mailer.govdelivery_tms_settings = {
      auth_token: Figaro.env.govdelivery_key,
      api_root: Figaro.env.govdelivery_host
    }
  end
end
