# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Slack::ReportService do
  describe 'Slack report service' do
    subject { described_class.new }

    before do
      create(:event, :sandbox_signup)
    end

    it 'sends a valid report' do
      VCR.use_cassette('slack/report_200', match_requests_on: [:method]) do
        result = subject.send_weekly_report
        expect(result.ok).to be(true)
      end
    end
  end
end
