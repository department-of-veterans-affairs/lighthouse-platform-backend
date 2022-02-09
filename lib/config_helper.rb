# frozen_string_literal: true

module ConfigHelper
  module_function

  def setup_action_mailer(config)
    config.action_mailer.show_previews = Rails.root.join('spec', 'mailers', 'previews')
    config.action_mailer.show_previews = Rails.env.development?
    config.action_mailer.perform_deliveries = Rails.env.production?
  end

end
