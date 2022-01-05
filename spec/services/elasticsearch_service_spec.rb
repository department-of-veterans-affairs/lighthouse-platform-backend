# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ElasticsearchService do
  before(:all) do
    ElasticsearchService.new.seed_elasticsearch
  rescue RuntimeError
    # assume valid state
  end

  describe '.intialize' do
    let(:subject) { ElasticsearchService.new }

    it 'uses regular Net::HTTP to make a connection' do
      expect(subject.client.name).to eq('Net::HTTP')
    end
  end
end
