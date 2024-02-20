# frozen_string_literal: true

class KongDriftJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Kong::DriftService.new.detect_drift if Flipper.enabled?(:alert_drift)
  end
end
