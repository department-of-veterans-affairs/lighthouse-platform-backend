# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoService do
  describe 'importing consumers from dynamo and Kong' do
    let(:dynamo_db_user_count) { 2 }

    before(:all) do
      DynamoService.new.initialize_dynamo_db
      DynamoService.new.seed_dynamo_db(dynamo_db_user_count)
    rescue Aws::DynamoDB::Errors::ResourceInUseException
      # assume valid state
    end

    it 'imports the users' do
      service = DynamoService.new
      results = service.fetch_dynamo_db
      expect(results.count).to eq(dynamo_db_user_count)
    end
  end
end
