# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::ProductionService do
  let(:consumer_name) { 'kong-consumer' }

  describe '.intialize' do
    subject { Kong::ProductionService.new }

    it 'uses regular Net::HTTP to make a connection' do
      expect(subject.client.name).to eq('Net::HTTP')
    end
  end

  describe 'hits the production Kong gateway' do
    it 'by default' do
      expect(subject.instance_variable_get(:@kong_elb)).to eq(Figaro.env.prod_kong_elb)
    end

    it 'sets the correct values for production' do
      expect(subject.send(:kong_elb)).to eq(Figaro.env.prod_kong_elb)
      expect(subject.send(:kong_password)).to eq(Figaro.env.prod_kong_password)
    end
  end
end
