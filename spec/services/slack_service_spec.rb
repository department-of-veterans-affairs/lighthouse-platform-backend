# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackService do
  describe 'slack service' do
    subject { SlackService.new }

    it 'uses the respective webhook and message' do
      VCR.use_cassette('slack/alert_200', match_requests_on: [:method]) do
        result = subject.alert_slack(Figaro.env.drift_webhook, { text: 'test' })
        expect(result.code).to eq('200')
        expect(result).to include('server')
        expect(result).to include('x-slack-backend')
      end
    end
  end
end
