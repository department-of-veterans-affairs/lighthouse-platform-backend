# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::DriftService do
  subject { Kong::DriftService.new }

  describe 'detects drifts' do
    it 'filters and alerts slack if needed' do
      allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
      result = subject.detect_drift
      expect(result.class).to eq(Array)
    end
  end
end
