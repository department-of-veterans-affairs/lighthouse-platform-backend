# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoImportService do
  subject { DynamoImportService.new }

  let(:mock_response) { Struct.new(:items) }

  def dynamo_mock_response
    mock_response.new([{
                        'kongConsumerId' => '262963e8-de6a-4a3f-8c65-694a52f4dcb6',
                        'tosAccepted' => true,
                        'apis' => 'facilities',
                        'organization' => 'StarkIndustries',
                        'lastName' => 'Stark',
                        'createdAt' => '2019-09-23T15:41:27.744Z',
                        'oAuthRedirectURI' => nil,
                        'description' => 'Testing',
                        'email' => 'tony@stark.com',
                        'firstName' => 'Tony'
                      },
                       {
                         'apis' => 'benefits,communityCare,confirmation,facilities,vaForms',
                         'lastName' => 'Parker',
                         'okta_client_id' => '8gy5CeupBKntzKF121aW',
                         'createdAt' => '2020-01-16T19:18:49.117Z',
                         'email' => 'peter@parker.com',
                         'firstName' => 'Peter',
                         'tosAccepted' => true,
                         'kongConsumerId' => '4b7612f0-1f98-42a3-9eb0-8e55e7c63989',
                         'okta_application_id' => '8gy5CeupBKntzKF121aW',
                         'organization' => 'Avengers',
                         'oAuthRedirectURI' => 'http://localhost',
                         'description' => 'no description'
                       }])
  end

  describe 'dynamo service' do
    it 'provides an event builder' do
      results = subject.send(:build_events, dynamo_mock_response.items)
      expect(results.first[:content]).to eq(dynamo_mock_response.items.first)
    end

    it 'mass upserts all' do
      allow_any_instance_of(DynamoService).to receive(:fetch_dynamo_db).and_return(dynamo_mock_response)
      subject.import_dynamo_events
      expect(Event.count).to eq(2)
    end
  end
end
