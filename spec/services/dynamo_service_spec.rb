# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoService do
  describe 'importing consumers from dynamo and Kong' do
    before(:all) do
      DynamoService.new.initialize_dynamo_db
      DynamoService.new.seed_dynamo_db(2)
    rescue Aws::DynamoDB::Errors::ResourceInUseException
      # assume valid state
    end

    it 'imports the users' do
      service = DynamoService.new
      results = service.fetch_dynamo_db
      expect(results.count).to eq(2)
    end
  end
end
