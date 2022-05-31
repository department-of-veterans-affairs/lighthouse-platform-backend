# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::DriftService do
  subject { Kong::DriftService.new }

  let(:mock) do
    [
      {
        custom_id: null,
        created_at: Date.yesterday.to_time.to_i,
        id: '1234-22a8-4a6d-ba20-fd3b262a3o4d',
        tags: null,
        username: 'test_user_1'
      }
    ]
  end

  describe 'detects drifts' do
    it 'filters and alerts slack if needed' do
      VCR.use_cassette('kong/list_applications_200', match_requests_on: [:method]) do
        VCR.use_cassette('slack/kong_alert_200', match_requests_on: [:method]) do
          result = subject.detect_drift
          expect(result).to eq({ success: true })
        end
      end
    end
  end
end
