# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.ignore_actions = ['OkComputer::OkComputerController#show']

  config.lograge.custom_options = lambda do |_event|
    { time: Time.zone.now }
  end
end
