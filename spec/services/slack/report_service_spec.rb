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
        result = subject.send_weekly_report
        expect(result.ok).to be(true)
      end
    end

    it 'calculates the time span and total signups' do
      time_span_total, total = subject.send(:calculate_signups)
      expect(time_span_total).to eq(1)
      expect(total).to eq(1)
    end

    it 'calculates new and all time API signups via the events table' do
      results = subject.send(:calculate_new_and_all_time)
      api_ref = ApiRef.first.name
      grab_ref = results.filter { |api| api[:key] == api_ref }
      expect(grab_ref.first[:new_signups].count).to eq(1)
    end

    it 'builds an array to assist in calculating signups' do
      results = subject.send(:build_calculation_array)
      api_ref = ApiRef.first.name
      names = results.pluck(:key)

      expect(names).to include(api_ref)
      expect(results.first).to have_key(:key)
      expect(results.first).to have_key(:new_signups)
      expect(results.first).to have_key(:all_time_signups)
    end
  end
end
