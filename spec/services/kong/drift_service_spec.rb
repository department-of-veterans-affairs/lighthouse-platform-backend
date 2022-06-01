# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::DriftService do
  subject { Kong::DriftService.new }

  describe 'detects drifts' do
    it 'filters and alerts slack if needed' do
      VCR.use_cassette('slack/kong_alert_200', match_requests_on: [:method]) do
        result = subject.detect_drift
        expect(result).to eq({ success: true })
      end
    end
  end
end