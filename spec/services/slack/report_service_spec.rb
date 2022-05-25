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

    it 'calculates new and all time API signups via the events table' do
      results = subject.send(:generate_query).first
      api_ref = ApiRef.all.map(&:name)
      expect(results).to include(api_ref.first).or include(api_ref.last)
    end

    it 'build the query for new signups' do
      api_ref = ApiRef.first.name
      results = subject.send(:new_query, api_ref)
      expect(results).to include("content->>'apis' LIKE '%#{api_ref}%'")
    end

    it 'build the query for all time signups' do
      api_ref = ApiRef.first.name
      results = subject.send(:all_time_query, api_ref)
      expect(results).to include("content->>'apis' LIKE '%#{api_ref}%'")
    end

    it 'builds the query for connection' do
      api_refs = ApiRef.all.map(&:name)
      results = subject.send(:build_query)
      expect(results).to include(api_refs.first)
      expect(results).to include(api_refs.last)
      expect(results).to include('weekly_count')
      expect(results).to include('total_count')
    end
  end
end
