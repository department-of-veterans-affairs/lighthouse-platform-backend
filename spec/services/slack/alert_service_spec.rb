# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Slack::AlertService do
  describe 'slack service' do
    subject { Slack::AlertService.new }

    it 'uses the respective webhook and message' do
      VCR.use_cassette('slack/alert_200', match_requests_on: [:method]) do
        result = subject.send_message(Figaro.env.slack_drift_channel, { text: 'test' })
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
        result = subject.send_message(Figaro.env.slack_signup_channel, message)
        expect(result.ok).to be(true)
      end
    end

    it 'raises an error when provided an incorrect key' do
      message = {
        invalid: [
          {
            text: 'test'
          }
        ]
      }
      expect { subject.send_message(Figaro.env.slack_signup_channel, message) }.to raise_error(RuntimeError)
    end
  end
end
