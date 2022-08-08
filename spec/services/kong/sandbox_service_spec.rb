# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::SandboxService do
  let(:consumer_name) { 'kong-consumer' }

  describe '.intialize' do
    subject { Kong::SandboxService.new }

    it 'uses regular Net::HTTP to make a connection' do
      expect(subject.client.name).to eq('Net::HTTP')
    end
  end

  describe 'hits the sandbox Kong gateway' do
    it 'by default' do
      expect(subject.instance_variable_get(:@kong_elb)).to eq(Figaro.env.kong_elb)
    end

    it 'sets the correct values for sandbox' do
      expect(subject.send(:kong_elb)).to eq(Figaro.env.kong_elb)
      expect(subject.send(:kong_password)).to eq(Figaro.env.kong_password)
    end
  end

  describe '#list_consumers' do
    it 'retrieves a list of consumers' do
      result = subject.list_consumers
      expect(result['data'].length > 0).to be_truthy
    end
  end

  describe '#list_all_consumers' do
    it 'retrieves a list of all consumers' do
      result = subject.list_all_consumers
      expect(result.length > 0).to be_truthy
    end
  end

  describe '#get_consumer' do
    it 'retrieves a consumer via an ID' do
      result = subject.get_consumer(consumer_name)
      expect(result['username']).to eq(consumer_name)
    end
  end

  describe '#get_acls' do
    it 'retrieves a list of ACLs for the given consumer' do
      result = subject.get_acls(consumer_name)
      expect(result['data'].length).to satisfy { |r| [0, 1].include?(r) }
    end
  end

  describe '#get_plugins' do
    it 'retrieves a list of plugins applied to the consumer' do
      result = subject.get_plugins(consumer_name)
      expect(result['data'].length).to eq(0)
    end
  end
end
