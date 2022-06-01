# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::DriftService do
  subject { Kong::DriftService.new }

  let(:consumers) do
    [
      { 'custom_id' => nil, 'created_at' => Date.yesterday.to_time.to_i,
        'id' => '123453-test1-46c0-a1bd-a0c48c918ce5', 'tags' => nil, 'username' => 'martin_gore' },
      { 'custom_id' => nil, 'created_at' => Date.yesterday.to_time.to_i,
        'id' => '342342-test2-45ca-a272-33119127f11f', 'tags' => nil, 'username' => 'dave_gahan' },
      { 'custom_id' => nil, 'created_at' => 1_652_995_720, 'id' => '3gfy3y-test3-41b7-97c3-792cae53f6f3',
        'tags' => nil, 'username' => 'andy_fletcher' },
      { 'custom_id' => nil, 'created_at' => 1_653_512_958, 'id' => '324iuy-test4-4fdf-b86d-a481b2643869',
        'tags' => nil, 'username' => 'vince_clarke' },
      { 'custom_id' => nil, 'created_at' => 1_653_513_692, 'id' => 'sdfuiy-test5-4d87-b167-77ab3fc81a5f',
        'tags' => nil, 'username' => 'alan_wilder' }
    ]
  end

  let(:kong_consumers) do
    []
  end

  describe 'detects drifts' do
    it 'filters and alerts slack if needed' do
      VCR.use_cassette('slack/kong_alert_200', match_requests_on: [:method]) do
        result = subject.detect_drift
        expect(result).to eq({ success: true })
      end
    end

    describe 'has private methods' do
      it 'filters via last day' do
        VCR.use_cassette('kong/kong_consumers_200') do
          result = subject.send(:filter_last_day, consumers)
          expect(result.length).to eq(2)
        end
      end

      it 'locates unknown entries' do
        result = subject.send(:detect_unknown_entities, consumers)
        expect(result.length).to eq(5)
      end
    end
  end
end
