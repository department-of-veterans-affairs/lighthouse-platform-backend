# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoService do
  describe 'importing consumers from dynamo and Kong' do
    it 'imports the users' do
      service = described_class.new
      results = service.fetch_dynamo_db
      expect(results.count).to eq(2)
    end
  end
end
