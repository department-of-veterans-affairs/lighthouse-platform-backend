# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Okta::DriftService do
  subject { Okta::DriftService.new }

  let(:mock) do
    [
      {
        created: Time.zone.now,
        label: 'r34l_l4b3l',
        credentials: {
          oauthClient: {
            client_id: '1234'
          }
        }
      }
    ]
  end

  describe 'detects drifts' do
    it 'filters and alerts slack if needed' do
      VCR.use_cassette('okta/list_applications_200', match_requests_on: [:method]) do
        VCR.use_cassette('slack/alert_200', match_requests_on: [:method]) do
          result = subject.detect_drift
          expect(result).to eq({ success: true })
        end
      end
    end
  end

  describe 'has private methods' do
    it 'filters via last day' do
      result = subject.send(:filter_last_day, mock)
      expect(result.length).to eq(1)
    end

    it 'does not return -dev entries' do
      mock_failure = [{ created: Time.zone.now, label: 'Isit123456-dev' }]
      result = subject.send(:filter_last_day, mock_failure)
      expect(result.length).to eq(0)
    end

    it 'locates unknown entries' do
      result = subject.send(:detect_unknown_entities, mock)
      expect(result.length).to eq(1)
    end

    it 'can alert slack if needed' do
      VCR.use_cassette('slack/alert_200', match_requests_on: [:method]) do
        result = subject.send(:alert_slack, mock.first)
        expect(result.code).to eq('200')
        expect(result).to include('server')
        expect(result).to include('x-slack-backend')
      end
    end
  end
end
