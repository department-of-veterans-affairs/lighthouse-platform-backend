# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Slack::ReportService do
  describe 'Slack report service' do
    subject { Slack::ReportService.new }

    before do
      create(:event, :sandbox_signup)
    end

    it 'sends a valid report' do
      VCR.use_cassette('slack/report_200', match_requests_on: [:method]) do
        result = subject.send_report('week', 1.week.ago)
        expect(result.class).to be(Hash)
      end
    end
  end
end
