# frozen_string_literal: true

require 'sidekiq-scheduler'

class OktaDriftJob
  include Sidekiq::Worker

  def perform
    Okta::DriftService.new.detect_drift if Flipper.enabled?(:alert_drift)
    Okta::DriftService.new(:production).detect_drift if Flipper.enabled?(:alert_drift)
  end
end
