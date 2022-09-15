# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apigee::ProductionService do
  describe '.intialize' do
    subject { Apigee::ProductionService.new }

    it 'uses regular Net::HTTP to make a connection' do
      expect(subject.client.name).to eq('Net::HTTP')
    end
  end

  describe 'hits the production Apigee gateway' do
    it 'by default' do
      expect(subject.instance_variable_get(:@apigee)).to eq(Figaro.env.apigee_prod_gateway)
    end

    it 'sets the correct values for production' do
      expect(subject.send(:apigee_gateway)).to eq(Figaro.env.apigee_prod_gateway)
      expect(subject.send(:apigee_gateway_apikey)).to eq(Figaro.env.apigee_gateway_prod_apikey)
    end
  end
end
