# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::SandboxService do
  let(:mock_response) { Struct.new(:items) }

  describe 'importing consumers from dynamo and Kong' do
    let(:facilities_api) { create(:api, name: 'Facilities', acl: 'va_facilities') }

    before do
      create(:api_ref, name: 'facilities', api_id: facilities_api.id)
    end

    it 'imports the the users' do
      allow_any_instance_of(described_class).to receive(:list_all_consumers).and_return(kong_mock_response)
      allow_any_instance_of(DynamoService).to receive(:fetch_dynamo_db).and_return(dynamo_mock_response)
      allow_any_instance_of(Okta::SandboxService).to receive(:list_applications).and_return(okta_mock_response)
      service = ConsumerImportService.new
      expect do
        service.import
      end.to change(User, :count).by(1)
    end

    def kong_mock_response
      [
        {
          'id' => '262963e8-de6a-4a3f-8c65-694a52f4dcb6'
        }
      ]
    end

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

    def okta_mock_response
      {
      }
    end
  end
end
