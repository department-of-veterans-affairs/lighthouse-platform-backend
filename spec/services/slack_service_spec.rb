# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackService do
  describe 'slack service' do
    subject { SlackService.new }

    it 'uses the respective webhook and message' do
      VCR.use_cassette('slack/alert_200', match_requests_on: [:method]) do
        result = subject.alert_slack(Figaro.env.slack_drift_channel, 'test')
        expect(result.ok).to be(true)
      end
    end

    it 'uses attachments when needed' do
      message = {
        attachments: [
          {
            color: 'good',
            fallback: 'Test Run',
            text: 'Test Run',
            title: 'New User Application'
          }
        ]
      }
      VCR.use_cassette('slack/signup_alert_200', match_requests_on: [:method]) do
        result = subject.alert_slack(Figaro.env.slack_signup_channel, message)
        expect(result.ok).to be(true)
      end
    end
  end
end
