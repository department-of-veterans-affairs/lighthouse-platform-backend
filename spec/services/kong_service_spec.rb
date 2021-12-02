# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KongService do
  let(:consumer_name) { 'kong-consumer' }

  before do
    KongService.new.seed_kong
  rescue RuntimeError
    # assume valid state
  end

  describe '.intialize' do
    let(:subject) { KongService.new }
  end

  describe '#list_consumers' do
    it 'retrieves a list of consumers' do
      result = subject.list_consumers
      expect(result['data'].length).to eq(2)
      expect(result['data'].collect do |consumer|
               consumer['username']
             end.sort).to eq(%w[kong-consumer lighthouse-consumer])
    end
  end

  describe '#get_consumer' do
    it 'retrieves a consumer via an ID' do
      result = subject.get_consumer(consumer_name)
      expect(result['username']).to eq(consumer_name)
    end
  end

  describe '#get_plugins' do
    it 'retrieves a list of plugins applied to the consumer' do
      result = subject.get_plugins(consumer_name)
      expect(result['data'].length).to eq(0)
    end
  end
end
