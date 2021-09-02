# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoService do
  describe 'importing consumers from dynamo and Kong' do
    it 'imports the the users' do
      VCR.use_cassette('imports/dynamo_import') do
        service = DynamoService.new
        results = service.fetch_dynamo_db
        expect(results['count']).to eq(427)
      end
    end
  end
end
