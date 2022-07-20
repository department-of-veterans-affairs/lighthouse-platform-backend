# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Slack::ReportService do
  describe 'Slack report service' do
    subject { Slack::ReportService.new }

    let!(:new_signup_event) { create(:event, :sandbox_signup) }

    it 'sends a valid report' do
      VCR.use_cassette('slack/report_200', match_requests_on: [:method]) do
        result = subject.send_report('week', 1.week.ago)
        expect(result.class).to be(Hash)
      end
    end

    context 'when other event types exist' do
      before do
        create(:event, event_type: Event::EVENT_TYPES[:lpb_signup], created_at: 1.month.ago)
      end

      it 'queries expected values' do
        result = subject.query_events('week', 1.week.ago)
        expect(result['weekly_count']).to eq(1)
      end
    end

    context 'when sandbox_signup event exists with invalid content' do
      before do
        create(:event, event_type: Event::EVENT_TYPES[:sandbox_signup], created_at: 1.month.ago, content: 'invalid')
      end

      it 'queries expected values' do
        result = subject.query_events('week', 1.week.ago)
        expect(result['weekly_count']).to eq(1)
      end
    end
  end
end
