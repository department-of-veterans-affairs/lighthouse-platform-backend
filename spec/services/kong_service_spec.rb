# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KongService do
  let(:consumer_id) { 'b11ae7d9-2949-4e80-aa55-ccd30d4c7287' }

  describe '.intialize' do
    let(:subject) { KongService.new }
  end

  describe '#list_consumers' do
    it 'retrieves a list of consumers' do
      result = subject.list_consumers
      expect(result['data'].length).to eq(2)
      expect(result['data'].last['username']).to eq('kong-consumer')
    end
  end

  describe '#get_consumer' do
    it 'retrieves a consumer via an ID' do
      result = subject.get_consumer(consumer_id)
      expect(result['username']).to eq('kong-consumer')
    end
  end

  describe '#get_plugins' do
    it 'retrieves a list of plugins applied to the consumer' do
      result = subject.get_plugins(consumer_id)
      expect(result['data'].length).to eq(0)
    end
  end
end
