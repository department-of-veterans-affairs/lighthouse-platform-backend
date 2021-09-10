# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoService do
  describe 'importing consumers from dynamo and Kong' do
    def mock_response
      {
        'Count' => 2,
        'Items' => [
          {
            'apis' => { 'S' => 'facilities' },
            'organization' => { 'S' => 'StarkIndustries' },
            'lastName' => { 'S' => 'Stark' },
            'createdAt' => { 'S' => '2019-09-23T15:41:27.744Z' },
            'oAuthRedirectURI' => { 'NULL' => true },
            'description' => { 'S' => 'Testing' },
            'email' => { 'S' => 'tony@stark.com' },
            'firstName' => { 'S' => 'Tony' },
            'kongConsumerId' => { 'S' => '66c675db-8099-43a1-ba61-46ce87e8d73b' },
            'tosAccepted' => { 'BOOL' => true }
          },
          {
            'apis' => { 'S' => 'facilities,verification' },
            'lastName' => { 'S' => 'Parker' },
            'okta_client_id' => { 'S' => 'yJQfQjbNECoiFVVEXXRG' },
            'createdAt' => { 'S' => '2020-08-06T13:33:22.180Z' },
            'email' => { 'S' => 'peter@parker.com' },
            'firstName' => { 'S' => 'Peter' },
            'tosAccepted' => { 'BOOL' => true },
            'kongConsumerId' => { 'S' => 'a3573e26-22fa-4a9f-beb6-5c7221dc3b59' },
            'okta_application_id' => { 'S' => 'yJQfQjbNECoiFVVEXXRG' },
            'organization' => { 'S' => 'School' },
            'oAuthRedirectURI' => { 'S' => 'https://fake-redirect.com' },
            'description' => { 'S' => 'no description' }
          }
        ]
      }
    end

    it 'imports the users' do
      service = DynamoService.new
      allow_any_instance_of(Aws::DynamoDB::Client).to receive(:scan).and_return(mock_response)
      results = service.fetch_dynamo_db
      expect(results['Count']).to eq(2)
    end
  end
end
