# frozen_string_literal: true

class OktaDriftJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Okta::DriftService.new.detect_drift if Flipper.enabled?(:alert_drift)
    Okta::DriftService.new(:production).detect_drift if Flipper.enabled?(:alert_drift)
  end
end
